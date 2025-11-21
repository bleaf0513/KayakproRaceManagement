#include "SharedData.h"

int global_playernum=10;
QList<QStringList> global_data;

SharedData::SharedData(QObject *parent) : QObject(parent) {
    global_data.resize(global_playernum+1);
    QStringList foot_data = { "No","First Name","Surname","Club","M/F","Cat","Weight","DOB" };
    global_data[0]= foot_data;
    for(int i=1;i<=global_playernum;i++)
    {
        global_data[i].resize(8);
    }
}
bool SharedData::setSharedItem(int player_index,int pos, const QString &data)
{
    if(player_index+1>global_playernum) return false;
    global_data[player_index+1].replace(pos,data);
    return true;
}
QVariantList SharedData::players() const
{
    QVariantList out;

    for (int i = 1; i <= global_playernum; ++i) {
        QVariantList row;
        for (int c = 0; c < global_data[i].size(); ++c)
            row << global_data[i].at(c);
        out << QVariant(row);
    }
    return out;
}
void SharedData::writeProfile()
{
    QSettings settings("KayakPro", "RaceApp");
    for(int i=0;i<global_playernum;i++)
    {
        QString prefix = QString("player%1/").arg(i+1);
        settings.setValue(prefix + "firstname", global_data[i+1].at(FIRSTNAME));
        settings.setValue(prefix + "surname", global_data[i+1].at(SURNAME));
        settings.setValue(prefix + "club", global_data[i+1].at(CLUB));
        settings.setValue(prefix + "mf", global_data[i+1].at(MF));
        settings.setValue(prefix + "cat", global_data[i+1].at(CAT));
        settings.setValue(prefix + "weight", global_data[i+1].at(WEIGHT));
        settings.setValue(prefix + "dob", global_data[i+1].at(DOB));
    }
}
void SharedData::readProfile()
{
    QSettings settings("KayakPro", "RaceApp");
    for(int i=0;i<global_playernum;i++)
    {
        QString prefix = QString("player%1/").arg(i+1);
        global_data[i+1].replace(LANE,QString::number(i+1));
        // Load values directly
        global_data[i+1].replace(FIRSTNAME, settings.value(prefix + "firstname", "").toString());
        global_data[i+1].replace(SURNAME,   settings.value(prefix + "surname", "").toString());
        global_data[i+1].replace(CLUB,      settings.value(prefix + "club", "").toString());
        global_data[i+1].replace(MF,        settings.value(prefix + "mf", "").toString());
        global_data[i+1].replace(CAT,       settings.value(prefix + "cat", "").toString());
        global_data[i+1].replace(WEIGHT,    settings.value(prefix + "weight", "").toString());
        global_data[i+1].replace(DOB,       settings.value(prefix + "dob", "").toString());
    }
    emit playersChanged();
}
