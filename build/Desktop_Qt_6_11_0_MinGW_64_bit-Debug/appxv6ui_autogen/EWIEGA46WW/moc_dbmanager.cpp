/****************************************************************************
** Meta object code from reading C++ file 'dbmanager.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.11.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../dbmanager.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'dbmanager.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 69
#error "This file was generated using the moc from 6.11.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

#ifndef Q_CONSTINIT
#define Q_CONSTINIT
#endif

QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
QT_WARNING_DISABLE_GCC("-Wuseless-cast")
namespace {
struct qt_meta_tag_ZN9DbManagerE_t {};
} // unnamed namespace

template <> constexpr inline auto DbManager::qt_create_metaobjectdata<qt_meta_tag_ZN9DbManagerE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "DbManager",
        "getLatestCpuMetrics",
        "QVariantList",
        "",
        "getTimelineMetrics",
        "getAverageCpuUsage",
        "getProcessStatesCount",
        "QVariantMap"
    };

    QtMocHelpers::UintData qt_methods {
        // Method 'getLatestCpuMetrics'
        QtMocHelpers::MethodData<QVariantList()>(1, 3, QMC::AccessPublic, 0x80000000 | 2),
        // Method 'getTimelineMetrics'
        QtMocHelpers::MethodData<QVariantList()>(4, 3, QMC::AccessPublic, 0x80000000 | 2),
        // Method 'getAverageCpuUsage'
        QtMocHelpers::MethodData<int()>(5, 3, QMC::AccessPublic, QMetaType::Int),
        // Method 'getProcessStatesCount'
        QtMocHelpers::MethodData<QVariantMap()>(6, 3, QMC::AccessPublic, 0x80000000 | 7),
    };
    QtMocHelpers::UintData qt_properties {
    };
    QtMocHelpers::UintData qt_enums {
    };
    return QtMocHelpers::metaObjectData<DbManager, qt_meta_tag_ZN9DbManagerE_t>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}
Q_CONSTINIT const QMetaObject DbManager::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN9DbManagerE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN9DbManagerE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN9DbManagerE_t>.metaTypes,
    nullptr
} };

void DbManager::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<DbManager *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: { QVariantList _r = _t->getLatestCpuMetrics();
            if (_a[0]) *reinterpret_cast<QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 1: { QVariantList _r = _t->getTimelineMetrics();
            if (_a[0]) *reinterpret_cast<QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 2: { int _r = _t->getAverageCpuUsage();
            if (_a[0]) *reinterpret_cast<int*>(_a[0]) = std::move(_r); }  break;
        case 3: { QVariantMap _r = _t->getProcessStatesCount();
            if (_a[0]) *reinterpret_cast<QVariantMap*>(_a[0]) = std::move(_r); }  break;
        default: ;
        }
    }
}

const QMetaObject *DbManager::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *DbManager::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN9DbManagerE_t>.strings))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int DbManager::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 4)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 4;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 4)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 4;
    }
    return _id;
}
QT_WARNING_POP
