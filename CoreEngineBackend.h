#ifndef COREENGINEBACKEND_H
#define COREENGINEBACKEND_H

#include <QObject>
#include <QVariantList>
#include <QTimer>
#include <QSqlDatabase>

class CoreEngineBackend : public QObject
{
    Q_OBJECT

    // BUFFER CACHE
    Q_PROPERTY(int totalBuffers READ totalBuffers NOTIFY dataChanged)
    Q_PROPERTY(int busyBuffers READ busyBuffers NOTIFY dataChanged)
    Q_PROPERTY(int freeBuffers READ freeBuffers NOTIFY dataChanged)
    Q_PROPERTY(double usagePercent READ usagePercent NOTIFY dataChanged)

    // HIT RATE
    Q_PROPERTY(QString hitRate READ hitRate NOTIFY dataChanged)
    Q_PROPERTY(QString hits READ hits NOTIFY dataChanged)
    Q_PROPERTY(QString misses READ misses NOTIFY dataChanged)

    // INODES
    Q_PROPERTY(QString activeInodes READ activeInodes NOTIFY dataChanged)
    Q_PROPERTY(QString usedInodes READ usedInodes NOTIFY dataChanged)
    Q_PROPERTY(QString freeInodes READ freeInodes NOTIFY dataChanged)

    // LOG
    Q_PROPERTY(QString logStatus READ logStatus NOTIFY dataChanged)
    Q_PROPERTY(QString outstanding READ outstanding NOTIFY dataChanged)
    Q_PROPERTY(QString committing READ committing NOTIFY dataChanged)

    // MODELS
    Q_PROPERTY(QVariantList bufferModel READ bufferModel NOTIFY dataChanged)
    Q_PROPERTY(QVariantList timelineModel READ timelineModel NOTIFY timelineChanged)
    Q_PROPERTY(QVariantList recentEventsModel READ recentEventsModel NOTIFY dataChanged)

    // INSPECTOR
    Q_PROPERTY(QString inspectorText READ inspectorText NOTIFY inspectorChanged)

    Q_PROPERTY(QVariantList directoryTreeModel READ directoryTreeModel NOTIFY dataChanged)
    Q_PROPERTY(QVariantList fdTableModel READ fdTableModel NOTIFY dataChanged)

public:
    explicit CoreEngineBackend(QObject *parent = nullptr);

    int totalBuffers() const;
    int busyBuffers() const;
    int freeBuffers() const;
    double usagePercent() const;

    QString hitRate() const;
    QString hits() const;
    QString misses() const;

    QString activeInodes() const;
    QString usedInodes() const;
    QString freeInodes() const;

    QString logStatus() const;
    QString outstanding() const;
    QString committing() const;

    QVariantList bufferModel() const;
    QVariantList timelineModel() const;
    QVariantList recentEventsModel() const;

    QString inspectorText() const;

    Q_INVOKABLE void refreshTimeline(QString pid = "");
    Q_INVOKABLE void inspectEvent(int eventId);

    QVariantList directoryTreeModel() const;
    QVariantList fdTableModel() const;

signals:
    void dataChanged();
    void timelineChanged();
    void inspectorChanged();

private:
    void refreshData();
    QSqlDatabase m_db;
    QTimer m_timer;
    QTimer m_timelineTimer;
    int m_totalBuffers = 0;
    int m_busyBuffers = 0;
    int m_freeBuffers = 0;
    double m_usagePercent = 0;

    QString m_hitRate;
    QString m_hits;
    QString m_misses;

    QString m_activeInodes;
    QString m_usedInodes;
    QString m_freeInodes;

    QString m_logStatus;
    QString m_outstanding;
    QString m_committing;

    QVariantList m_bufferModel;
    QVariantList m_timelineModel;
    QVariantList m_recentEventsModel;

    QString m_inspectorText;

    QVariantList m_directoryTreeModel;
    QVariantList m_fdTableModel;

};

#endif