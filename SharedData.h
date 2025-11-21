#pragma once
#include <QObject>
#include <QString>
#include <QStringList>
#include <QSettings>
extern QList<QStringList> global_data;
extern int global_playernum;

enum PLAER_PROPERTY_INDEX{
    LANE,
    FIRSTNAME,
    SURNAME,
    CLUB,
    MF,
    CAT,
    WEIGHT,
    DOB
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

    // Return players for QML model
    QVariantList players() const;
private:
    QString m_playerName;
signals:
    void playersChanged();
};
