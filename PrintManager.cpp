#include "PrintManager.h"
#include <QFile>
#include <QTextStream>
#include <QPainter>
#include <QPrinter>
#include <QString>
#include <QStringList>
#include <QDir>

extern QList<QStringList> global_data;
PrintManager::PrintManager(QObject *parent)
    : QObject(parent) {}

QStringListList PrintManager::parseCsv(const QString &csvPath)
{
    QStringListList table;
    QFile file(csvPath);

    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return table;

    QTextStream in(&file);
    while (!in.atEnd()) {
        QString line = in.readLine();
        table.append(line.split(","));
    }
    return table;
}
QString PrintManager::saveCsvFile(const QString &fileName, const QStringListList &rows)
{
    // Ensure directory exists
    QFile file(fileName);
    QFileInfo info(file);
    QDir dir = info.dir();
    if (!dir.exists()) {
        dir.mkpath(".");
    }

    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning("Cannot open file for writing: %s", qUtf8Printable(fileName));
        return QString();
    }

    QTextStream out(&file);

    for (const QStringList &row : rows) {
        // Escape commas by quoting the field if necessary
        qWarning()<<"DDDD"<<row;
        QStringList escapedRow;
        for (const QString &field : row) {
            QString s = field;
            if (s.contains(',') || s.contains('"')) {
                s.replace('"', "\"\"");      // Escape quotes
                s = "\"" + s + "\"";         // Wrap in quotes
            }
            escapedRow << s;
        }
        out << escapedRow.join(",") << "\n";
    }

    file.close();
    return fileName;
}
void PrintManager::saveCsv()
{
    saveCsvFile("race_record.csv",global_data);
}
void PrintManager::renderTable(QPainter &painter, const QStringListList &rows, QPrinter &printer)
{
    if (rows.isEmpty()) return;

    painter.setFont(QFont("Arial", 12));

    const int margin = 150;
    int colCount = rows.first().size();


    int pageWidth  = printer.pageRect(QPrinter::DevicePixel).width();
    int pageHeight = printer.pageRect(QPrinter::DevicePixel).height();
    int tableWidth = pageWidth - margin * 2;
    int colWidth = tableWidth / colCount;
    int tableHeight = pageHeight - margin * 2;
    int rowHeight = 120;//tableHeight/ rows.count();
    int y = margin;
    int rowIndex = 0;
    QFont f = painter.font();
    while (rowIndex < rows.size()) {
        if (y + rowHeight > pageHeight - margin) {
            printer.newPage();  // <-- correct call
            y = margin;
        }

        const QStringList &row = rows[rowIndex];
        int x = margin;

        for (const QString &cell : row) {
            QRect rect(x, y, colWidth, rowHeight);
            painter.drawRect(rect);
            float font_size = 24.0;
            float temp=rowHeight*0.96;
            if(cell.length()>0)
            {
                font_size = colWidth/cell.length();
                if(font_size>temp)
                    font_size = temp;
            }
            else
                font_size = temp;
            if(font_size< temp)
                font_size*=1.3;
            f.setPixelSize((int)font_size);   // decrease size by 4
            painter.setFont(f);
            painter.drawText(rect.adjusted(5,5,-5,-5), Qt::AlignHCenter | Qt::AlignVCenter, cell);
            x += colWidth;
        }

        y += rowHeight;
        rowIndex++;
    }
}

bool PrintManager::printCsv(const QString &csvPath)
{
    QStringListList rows = parseCsv(csvPath);
    if (rows.isEmpty()) return false;

    QPrinter printer(QPrinter::HighResolution);
    printer.setPageSize(QPageSize::A4);

    QPageLayout layout = printer.pageLayout();
    if (layout.orientation() == QPageLayout::Portrait)
        layout.setOrientation(QPageLayout::Landscape);

    printer.setPageLayout(layout);
    QPainter painter(&printer);
    if (!painter.isActive()) return false;

    renderTable(painter, rows, printer);

    painter.end();
    return true;
}

bool PrintManager::savePdf(const QString &csvPath, const QString &pdfPath)
{
    QStringListList rows = parseCsv(csvPath);
    if (rows.isEmpty()) return false;

    QPrinter printer(QPrinter::HighResolution);
    printer.setOutputFormat(QPrinter::PdfFormat);
    printer.setOutputFileName(pdfPath);

    QPainter painter(&printer);
    if (!painter.isActive()) return false;

    renderTable(painter, rows, printer);

    painter.end();
    return true;
}
