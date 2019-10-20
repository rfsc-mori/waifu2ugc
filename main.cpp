#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QQuickWindow>
#include <QQmlContext>
#include <QLoggingCategory>

#include "templateexporter.h"
#include "templateface.h"

int main(int argc, char* argv[])
{
	QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

	QApplication app(argc, argv);

	app.setOrganizationName("Aruraune");
	app.setOrganizationDomain("Aruraune");
	app.setApplicationName("waifu2ugc");
	app.setApplicationDisplayName("waifu2ugc");
	app.setApplicationVersion("1.0-alpha");

	QQuickStyle::setStyle("Default");

	qmlRegisterSingletonType<TemplateExporter>("waifu2ugc", 1, 0, "TemplateExporter", &TemplateExporter::qmlInstance);
	qmlRegisterUncreatableType<TemplateFace>("waifu2ugc", 1, 0, "TemplateFace", "TemplateFace cannot be created in QML.");

	QQmlApplicationEngine engine;

	const QUrl url(QStringLiteral("qrc:/main.qml"));
	QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
					 &app, [url](QObject* obj, const QUrl& objUrl) {
		if (!obj && url == objUrl)
			QCoreApplication::exit(-1);
	}, Qt::QueuedConnection);
	engine.load(url);

	return app.exec();
}
