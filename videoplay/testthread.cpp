#include "testthread.h"

TestThread::TestThread() :QThread ()
{

}

void TestThread::run()
{
    int number = 0;
    while(1){
        qDebug()<<"子线程 number ="<<number;
        number++;
        sleep(1);
    }
}
