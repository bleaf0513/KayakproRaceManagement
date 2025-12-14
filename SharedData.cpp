#include "SharedData.h"
#include "BluetoothManager.h"
int global_playernum=0;
int global_totaldist=0;
int global_setting_page_click=0;
QList<QStringList> global_data;
extern QList<KayakConsole> consoles;
SharedData::SharedData(QObject *parent) : QObject(parent) {
    static bool done = false;
    if (done) return;
    done = true;

    if(global_data.size()==0)
    {
        global_data.resize(10+1);
        QStringList foot_data = { "No","First Name","Surname","Club","M/F","Cat","Weight","DOB","MAC","Active","Distance","Time","Ranking"};
        global_data[0]= foot_data;

        for(int i=1;i<=10;i++)
        {
            global_data[i].resize(13);
            // global_data[i].replace(8,"");
            global_data[i].replace(BLUEACTIVE,"0");
            global_data[i].replace(LANE,QString::number(i));
            global_data[i].replace(LACEDIST,"0");
            global_data[i].replace(LACETIME,"0");
            global_data[i].replace(RANKING,"0");
        }
    }
}
void SharedData::setTotalDist(int dist){global_totaldist=dist;}
int SharedData::getTotalDist(){return global_totaldist;}
void SharedData::setPlayerNum(int nn)
{
    global_playernum=nn;
}
bool SharedData::setSharedItem(int player_index,int pos, const QString &data)
{
    if(player_index+1>10) return false;
    global_data[player_index+1].replace(pos,data);
    return true;
}
QVariantList SharedData::players() const
{
    QVariantList out;

    for (int i = 1; i <= 10; ++i) {
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
    for(int i=0;i<10;i++)
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
    for(int i=0;i<10;i++)
    {
        QString prefix = QString("player%1/").arg(i+1);
        global_data[i+1].replace(LANE,QString::number(i+1));
        qWarning()<<"DDDSSS"<<global_data[i+1].at(LANE);
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
int SharedData::isActive(int consoleIndex){
    if(global_data[consoleIndex+1].at(9)=="1")
    {

        //qWarning()<<"isActive:"<<consoleIndex;
        return 1;
    }
    else if(global_data[consoleIndex+1].at(9)=="-1")
        return -1;

    return 0;
}
QString SharedData::blueMacAddress(int consoleIndex)  {
    if (consoleIndex < 0 || consoleIndex >= 10)
        return "";
    QSettings settings("KayakPro", "BlueMacAddr");
    QString prefix = QString("%1").arg(consoleIndex);
    QString add=settings.value(prefix, "").toString();
    global_data[consoleIndex+1].replace(BLUEMAC,add);
    //qDebug() << "Console:blue"<<consoleIndex<<":"<<add;
    return add;
}
// QString SharedData::blueNames(int consoleIndex)  {
//     if (consoleIndex < 0 || consoleIndex >= 10)
//         return "";
//     QSettings settings("KayakPro", "BlueName");
//     QString prefix = QString("%1").arg(consoleIndex);
//     QString add=settings.value(prefix, "").toString();
//     global_data[consoleIndex+1].replace(BLUENAME,add);
//     qDebug() << "Console:blueName"<<consoleIndex<<":"<<add;
//     return add;
// }
QString SharedData::playerName(int consoleIndex)  {
    if (consoleIndex < 0 || consoleIndex >= 10)
        return "";
    return global_data[consoleIndex+1].at(FIRSTNAME)+" "+global_data[consoleIndex+1].at(SURNAME);
}
/*
        flags       = uint8Data[0] | (uint8Data[1] << 8);
        strokeRate  = uint8Data[2] / 2;
        strokeCount = uint8Data[3] | (uint8Data[4] << 8);
        distance    = uint8Data[5] | (uint8Data[6] << 8) | (uint8Data[7] << 16);
        pace        = uint8Data[8] | (uint8Data[9] << 8);
        instPower   = uint8Data[10] | (uint8Data[11] << 8);
        energyKJ    = uint8Data[12] | (uint8Data[13] << 8);
        kcal        = static_cast<quint16>(energyKJ * 0.239);
        heartRate   = uint8Data[17];
        elapsedTime = uint8Data[18] | (uint8Data[19] << 8);
*/
int SharedData::getDistance(int consoleIndex)
{
    //qWarning()<<"DISTANCE"<<consoles[consoleIndex].distance;
    return consoles[consoleIndex].distance;
}
int SharedData::getStrokeRate(int consoleIndex)
{
    return consoles[consoleIndex].strokeRate;
}
int SharedData::getStrokeCount(int consoleIndex)
{
    return consoles[consoleIndex].strokeCount;
}
QString SharedData::playerCat(int consoleIndex)  {
    if (consoleIndex < 0 || consoleIndex >= 10)
        return "";
    return global_data[consoleIndex+1].at(CAT);
}
void SharedData::setConfirmSetting(int flag)
{
    global_setting_page_click=flag;
}
int SharedData::isConfirmSetting()
{
    return global_setting_page_click;
}
