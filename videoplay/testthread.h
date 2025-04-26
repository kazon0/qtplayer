#ifndef TESTTHREAD_H
#define TESTTHREAD_H

#include <QThread>
#include <QDebug>

class TestThread :public QThread
{
public:
    TestThread();
    //QThread interface
protected:
    void run();
};

#endif // TESTTHREAD_H
