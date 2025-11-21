#pragma once
#include <QObject>
#include <QtPrintSupport/QPrinter>
#include <QtPrintSupport/QPrintDialog>
#include <QPainter>
#include <QList>
typedef QList<QStringList> QStringListList;
class PrintManager : public QObject
{
    Q_OBJECT
public:
    explicit PrintManager(QObject *parent = nullptr);

    Q_INVOKABLE bool printCsv(const QString &csvPath);
    Q_INVOKABLE bool savePdf(const QString &csvPath, const QString &pdfPath);
    Q_INVOKABLE void saveCsv();
private:
    QStringListList parseCsv(const QString &csvPath);
    void renderTable(QPainter &painter, const QStringListList &rows, QPrinter &printer);
    QString saveCsvFile(const QString &fileName, const QList<QStringList> &rows);
};
