#pragma once
#include <QObject>
#include <QString>
#include <QStringList>
#include <QSettings>

extern QList<QStringList> global_data;
extern int global_playernum;
extern int global_totaldist;
extern int global_setting_page_click;
enum PLAER_PROPERTY_INDEX{
    LANE,
    FIRSTNAME,
    SURNAME,
    CLUB,
    MF,
    CAT,
    WEIGHT,
    DOB,
    BLUEMAC,
    BLUEACTIVE,
    BLUENAME
};
class SharedData : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList players READ players NOTIFY playersChanged)
public:
    explicit SharedData(QObject *parent = nullptr);

    Q_INVOKABLE bool setSharedItem(int player_index,int pos, const QString &data);
    Q_INVOKABLE void writeProfile();
    Q_INVOKABLE void readProfile();
    Q_INVOKABLE int  isActive(int consoleIndex);
	    Q_INVOKABLE void setTotalDist(int dist);
    Q_INVOKABLE QString playerCat(int consoleIndex);
    Q_INVOKABLE int getTotalDist();
    Q_INVOKABLE QString playerName(int consoleIndex);
    Q_INVOKABLE int getDistance(int consoleIndex);
    Q_INVOKABLE int getStrokeRate(int consoleIndex);
    Q_INVOKABLE int getStrokeCount(int consoleIndex);
    Q_INVOKABLE void setPlayerNum(int nn);
    Q_INVOKABLE void setBlueMacAddress(int consoleIndex, const QVariant &name,const QVariant &mac) {
        if (consoleIndex < 0 || consoleIndex >= 9)
            return;
        m_blueNames[consoleIndex] = name.toString();
        m_macAddresses[consoleIndex] = mac.toString();
        qWarning()<<"BlueName"<<m_blueNames[consoleIndex];
        QSettings settings1("KayakPro","BlueName");
        QString prefix = QString("%1").arg(consoleIndex);
        settings1.setValue(prefix, m_blueNames[consoleIndex]);
        settings1.sync();

        QSettings settings("KayakPro", "BlueMacAddr");
        settings.setValue(prefix, m_macAddresses[consoleIndex]);
        global_data[consoleIndex+1].replace(10,m_blueNames[consoleIndex]);
        global_data[consoleIndex+1].replace(8,m_macAddresses[consoleIndex]);
        //qDebug() << "ConsoleName" << m_blueNames[consoleIndex] << "MAC:" << m_macAddresses[consoleIndex];

    }

    Q_INVOKABLE QString blueMacAddress(int consoleIndex);
    Q_INVOKABLE QString blueNames(int consoleIndex);
    Q_INVOKABLE int getPlayerNum(){return global_playernum;}
    Q_INVOKABLE void setConfirmSetting(int);
    Q_INVOKABLE int isConfirmSetting();
    // Return players for QML model
    QVariantList players() const;

private:
    QString m_playerName;
    QString m_macAddresses[10];
    QString m_blueNames[10];
signals:
    void playersChanged();
};
