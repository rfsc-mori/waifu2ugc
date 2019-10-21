/*
 * MIT License
 *
 * Copyright (c) 2019 Aruraune
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
*/

#ifndef TEMPLATEEXPORTER_H
#define TEMPLATEEXPORTER_H

#include <QObject>
#include <QUrl>
#include <QQmlEngine>
#include <QFutureWatcher>

#include "templatedata.h"
#include "templateface.h"
#include "exportdata.h"

class QQmlFile;

class TemplateExporter : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QUrl templateUrl READ templateUrl WRITE setTemplateUrl NOTIFY urlChanged)
	Q_PROPERTY(bool canceled READ canceled WRITE setCanceled NOTIFY canceledChanged)
	Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
	Q_PROPERTY(qreal progress READ progress NOTIFY progressChanged)
	Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)
	Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusMessageChanged)
	Q_PROPERTY(TemplateFace* frontFace READ frontFace CONSTANT)
	Q_PROPERTY(TemplateFace* topFace READ topFace CONSTANT)
	Q_PROPERTY(TemplateFace* rightFace READ rightFace CONSTANT)
	Q_PROPERTY(TemplateFace* backFace READ backFace CONSTANT)
	Q_PROPERTY(TemplateFace* bottomFace READ bottomFace CONSTANT)
	Q_PROPERTY(TemplateFace* leftFace READ leftFace CONSTANT)

public:
	explicit TemplateExporter(QObject* parent = nullptr);

	QUrl templateUrl() const;
	void setTemplateUrl(const QUrl& templateUrl);

	bool canceled() const;
	void setCanceled(bool canceled);

	bool busy() const;
	qreal progress() const;

	QString errorMessage() const;
	QString statusMessage() const;

	TemplateFace* frontFace() const;
	TemplateFace* topFace() const;
	TemplateFace* rightFace() const;
	TemplateFace* backFace() const;
	TemplateFace* bottomFace() const;
	TemplateFace* leftFace() const;

	TemplateData copyData() const;
	ExportData exportData() const;

	static QObject* qmlInstance(QQmlEngine* engine, QJSEngine* scriptEngine);

	Q_INVOKABLE QString supportedImageTypes() const;

	Q_INVOKABLE QUrl alternativeResolve(const QString& path) const;
	Q_INVOKABLE bool directoryExists(const QUrl& url) const;

	Q_INVOKABLE void exportToDirectory(const QUrl& directory);
	Q_INVOKABLE void cancel();

signals:
	void urlChanged();
	void canceledChanged();
	void busyChanged();
	void progressChanged();
	void error(const QString& error);
	void errorMessageChanged();
	void statusMessageChanged();
	void aborted();
	void finished();

private slots:
	void processFinished();

	void setProgress(qreal progress);
	void setStatusMessage(const QString& message);

	void emitAborted();

	void templateImageFinished();

	void frontImageFinished();
	void topImageFinished();
	void rightImageFinished();
	void backImageFinished();
	void bottomImageFinished();
	void leftImageFinished();

private:
	QHash<QString, QImage> exportImages();

	void setBusy(bool busy);

	void setErrorMessage(const QString& message);
	void emitError(const QString& message);

	void checkLoaders();

	void startProcessing();
	void preloadImages();
	void imageLoaded(const QString& owner, QQmlFile* file);
	void processImage(TemplateFace* face, QImage& image) const;

	static void process(TemplateExporter* exporter, ExportData data, QHash<QString, QImage> images, QUrl destination);

private:
	TemplateData m_data;

	volatile bool m_canceled = false;

	bool m_busy = false;
	qreal m_progress = 0.0;

	static constexpr qreal m_preloadingStart =  0.0;
	static constexpr qreal m_preloadingTotal   = 10.0; // 0%-10% / 100%

	static constexpr qreal m_imageProcessingStart = m_preloadingStart + m_preloadingTotal;
	static constexpr qreal m_imageProcessingTotal   = 10.0; // 10%-20% / 100%

	static constexpr qreal m_exportStart = m_imageProcessingStart + m_imageProcessingTotal;
	static constexpr qreal m_exportTotal   = 80.0; // 20%-100% / 100%

	QHash< QString, QSharedPointer<QQmlFile> > m_loaders;
	QHash<QString, bool> m_loaderReady;

	QUrl m_exportUrl;

	QFutureWatcher<void>* m_watcher;

	TemplateFace* m_frontFace;
	TemplateFace* m_topFace;
	TemplateFace* m_rightFace;
	TemplateFace* m_backFace;
	TemplateFace* m_bottomFace;
	TemplateFace* m_leftFace;

	QString m_errorMessage;
	QString m_statusMessage;
};

#endif // TEMPLATEEXPORTER_H
