#ifndef THEORYWIDGET_H
#define THEORYWIDGET_H

#include <QWidget>
#include <QStackedWidget>
#include <QTextEdit>
#include <QPushButton>
#include <QVBoxLayout>
#include <QListWidget>

class TheoryWidget : public QWidget {
    Q_OBJECT

public:
    explicit TheoryWidget(QWidget *parent = nullptr);

private slots:
    void showOverview();
    void showFunctions();
    void showScenario();
    void onFunctionClicked(QListWidgetItem *item);

private:
    QStackedWidget *stack;
    QTextEdit *overviewText;
    QTextEdit *scenarioText;
    QListWidget *functionList;
    QTextEdit *functionDetail;

    void setupOverviewPage();
    void setupFunctionsPage();
    void setupScenarioPage();
};

#endif