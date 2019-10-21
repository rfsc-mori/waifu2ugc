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

#include "templateexporter.h"
#include "templateface.h"

#include <QtConcurrent/QtConcurrent>
#include <QImage>
#include <QQmlEngine>
#include <QQmlContext>
#include <QQmlFile>
#include <QPainter>
#include <QDir>
#include <QImageReader>

TemplateExporter::TemplateExporter(QObject* parent) :
	QObject(parent),
	m_watcher(new QFutureWatcher<void>(this)),
	m_frontFace(new TemplateFace("front", FaceData::FRONT, tr("Front"), this)),
	m_topFace(new TemplateFace("top", FaceData::TOP, tr("Top"), this)),
	m_rightFace(new TemplateFace("right", FaceData::RIGHT, tr("Right"), this)),
	m_backFace(new TemplateFace("back", FaceData::BACK, tr("Back"), this)),
	m_bottomFace(new TemplateFace("bottom", FaceData::BOTTOM, tr("Bottom"), this)),
	m_leftFace(new TemplateFace("left", FaceData::LEFT, tr("Left"), this))
{
	connect(m_watcher, &QFutureWatcher<void>::finished, this, &TemplateExporter::processFinished);
}

QUrl TemplateExporter::templateUrl() const {
	return m_data.templateUrl();
}

void TemplateExporter::setTemplateUrl(const QUrl& url)
{
	if (m_data.templateUrl() != url)
	{
		m_data.templateUrl() = url;
		emit urlChanged();
	}
}

bool TemplateExporter::canceled() const {
	return m_canceled;
}

void TemplateExporter::setCanceled(bool canceled) {
	if (m_canceled != canceled)
	{
		m_canceled = canceled;
		emit canceledChanged();
	}
}

void TemplateExporter::emitAborted()
{
	emit aborted();
}

bool TemplateExporter::busy() const {
	return m_busy;
}

void TemplateExporter::setBusy(bool busy) {
	if (m_busy != busy)
	{
		m_busy = busy;
		emit busyChanged();
	}
}

qreal TemplateExporter::progress() const {
	return m_progress;
}

void TemplateExporter::setProgress(qreal progress) {
	if (std::abs(m_progress - progress) > 0.005)
	{
		m_progress = progress;
		emit progressChanged();
	}
}

QString TemplateExporter::errorMessage() const {
	return m_errorMessage;
}

QString TemplateExporter::statusMessage() const {
	return m_statusMessage;
}

void TemplateExporter::setErrorMessage(const QString& message) {
	if (m_errorMessage != message)
	{
		m_errorMessage = message;
		emit errorMessageChanged();
	}
}

void TemplateExporter::emitError(const QString& message)
{
	setErrorMessage(message);
	emit error(message);
}

void TemplateExporter::setStatusMessage(const QString &message) {
	if (m_statusMessage != message)
	{
		m_statusMessage = message;
		emit statusMessageChanged();
	}
}

TemplateFace* TemplateExporter::frontFace() const
{
	return m_frontFace;
}

TemplateFace* TemplateExporter::topFace() const
{
	return m_topFace;
}

TemplateFace* TemplateExporter::rightFace() const
{
	return m_rightFace;
}

TemplateFace* TemplateExporter::backFace() const
{
	return m_backFace;
}

TemplateFace* TemplateExporter::bottomFace() const
{
	return m_bottomFace;
}

TemplateFace* TemplateExporter::leftFace() const
{
	return m_leftFace;
}

TemplateData TemplateExporter::copyData() const
{
	return m_data;
}

ExportData TemplateExporter::exportData() const
{
	ExportData data;

	data.source() = copyData();

	data.front() = m_frontFace->copyData();
	data.top() = m_topFace->copyData();
	data.right() = m_rightFace->copyData();
	data.back() = m_backFace->copyData();
	data.bottom() = m_bottomFace->copyData();
	data.left() = m_leftFace->copyData();

	return data;
}

QHash<QString, QImage> TemplateExporter::exportImages()
{
	QHash<QString, QImage> images;

	int count = 0;

	setProgress(m_imageProcessingStart);

	for (auto it = m_loaders.begin(); it != m_loaders.end(); ++it)
	{
		if (m_canceled)
		{
			break;
		}

		if (!it->isNull())
		{
			const auto* file = it->get();
			QImage& image = images[it.key()];

			if (image.loadFromData(file->dataByteArray()))
			{
				if (it.key() == m_frontFace->face())
				{
					processImage(m_frontFace, image);
				}
				else if (it.key() == m_topFace->face())
				{
					processImage(m_topFace, image);
				}
				else if (it.key() == m_rightFace->face())
				{
					processImage(m_rightFace, image);
				}
				else if (it.key() == m_backFace->face())
				{
					processImage(m_backFace, image);
				}
				else if (it.key() == m_bottomFace->face())
				{
					processImage(m_bottomFace, image);
				}
				else if (it.key() == m_leftFace->face())
				{
					processImage(m_leftFace, image);
				}
			}
		}

		++count;

		setStatusMessage(tr("%1/%2 images processed...").arg(count).arg(m_loaders.count()));
		setProgress(m_imageProcessingStart + count * m_imageProcessingTotal / m_loaders.count());
	}

	if (!m_canceled)
	{
		setProgress(m_imageProcessingStart + m_imageProcessingTotal);
	}
	else
	{
		setStatusMessage(tr("Canceled while preloading images."));
		setBusy(false);

		emitAborted();
	}

	return images;
}

void TemplateExporter::processImage(TemplateFace* face, QImage& image) const
{
	if (face->resizeSource())
	{
		if (face->preserveAspectRatio())
		{
			if (face->aspectRatioAction() == TemplateFace::FIT)
			{
				QSize size(face->faceRect().width() * face->horizontalCount(), face->faceRect().height() * face->verticalCount());

				QImage frame(face->fitRect().size(), QImage::Format_ARGB32);
				frame.fill(Qt::transparent);

				QPainter painter(&frame);
				painter.drawImage(face->fitRect().topLeft(), image, image.rect(), Qt::NoFormatConversion);

				image = frame.scaled(size, Qt::AspectRatioMode::IgnoreAspectRatio, Qt::TransformationMode::SmoothTransformation);
			}
			else if (face->aspectRatioAction() == TemplateFace::CROP)
			{
				QSize size(face->faceRect().width() * face->horizontalCount(), face->faceRect().height() * face->verticalCount());
				image = image.copy(face->cropRect()).scaled(size, Qt::AspectRatioMode::IgnoreAspectRatio, Qt::TransformationMode::SmoothTransformation);
			}
		}
		else
		{
			QSize size(face->faceRect().width() * face->horizontalCount(), face->faceRect().height() * face->verticalCount());
			image = image.scaled(size, Qt::AspectRatioMode::IgnoreAspectRatio, Qt::TransformationMode::SmoothTransformation);
		}
	}
}

QObject* TemplateExporter::qmlInstance(QQmlEngine* engine, QJSEngine* scriptEngine)
{
	Q_UNUSED(engine)
	Q_UNUSED(scriptEngine)

	return new TemplateExporter;
}

QString TemplateExporter::supportedImageTypes() const
{
	return "*." + QImageReader::supportedImageFormats().join(" *.");
}

QUrl TemplateExporter::alternativeResolve(const QString& path) const
{
	return QDir::isAbsolutePath(path) ? QUrl::fromLocalFile(path) : QUrl::fromLocalFile(QFileInfo(QDir::home(), path).absoluteFilePath());
}

bool TemplateExporter::directoryExists(const QUrl& url) const
{	
	return QDir(url.toLocalFile()).exists();
}

void TemplateExporter::exportToDirectory(const QUrl& directory)
{
	if (m_busy)
	{
		emitError(tr("waifu2ugc is already generating the files, please wait."));
	}
	else
	{
		if (directory.isLocalFile())
		{
			QDir pathTest(directory.toLocalFile());

			if (pathTest.exists())
			{
				m_canceled = false;

				setBusy(true);

				setStatusMessage(tr("Preparing images..."));
				setProgress(0);

				m_exportUrl = directory;
				preloadImages();
			}
			else
			{
				emitError(tr("Invalid output destination."));
			}
		}
		else
		{
			emitError(tr("The destination must be a local path."));
		}
	}
}

void TemplateExporter::cancel()
{
	setCanceled(true);
}

void TemplateExporter::startProcessing() {
	if (m_watcher->isRunning())
	{
		emitError(tr("Invalid state: Export process is already running."));
	}
	else
	{
		bool hasError = false;

		setStatusMessage(tr("Copying state..."));

		auto data = exportData();

		setStatusMessage(tr("Processing images..."));

		auto images = exportImages();

		for (auto it = images.begin(); it != images.end(); ++it)
		{
			if (it->isNull())
			{
				emitError(tr("An image could not be loaded from:\r\n'%1'").arg(m_loaders[it.key()]->url().toString()));

				hasError = true;
				break;
			}
		}

		if (!hasError)
		{
			setStatusMessage(tr("Starting..."));

			m_watcher->setFuture(QtConcurrent::run(&TemplateExporter::process, this, data, images, m_exportUrl));
		}
		else
		{
			setBusy(false);
		}
	}
}

void TemplateExporter::processFinished() {
	setStatusMessage("");
	setProgress(0);

	setBusy(false);

	if (m_canceled)
	{
		emitAborted();
	}

	emit finished();
}

void TemplateExporter::process(TemplateExporter* exporter, ExportData data, QHash<QString, QImage> images, QUrl destination)
{
	QMetaObject::invokeMethod(exporter, "setStatusMessage", Qt::QueuedConnection, Q_ARG(QString, tr("Worker started. Calculating...")));

	int xSize = std::max(1, data.getXAxisSize());
	int ySize = std::max(1, data.getYAxisSize());
	int zSize = std::max(1, data.getZAxisSize());

	QMap< FaceData::FaceIndex, std::function<bool(int, int, int)> > visible {
		{ FaceData::FRONT,  [     ](int, int, int z) { return z == 0; } },
		{ FaceData::TOP,    [     ](int, int y, int) { return y == 0; } },
		{ FaceData::RIGHT,  [xSize](int x, int, int) { return x == xSize - 1; } },
		{ FaceData::BACK,   [zSize](int, int, int z) { return z == zSize - 1; } },
		{ FaceData::BOTTOM, [ySize](int, int y, int) { return y == ySize - 1; } },
		{ FaceData::LEFT,   [     ](int x, int, int) { return x == 0; } }
	};

	QMap< FaceData::FaceIndex, std::function<QPoint(int, int, int)> > translate {
		{ FaceData::FRONT,  [            ](int x, int y, int) { return QPoint(x, y); } },
		{ FaceData::TOP,    [       zSize](int x, int, int z) { return QPoint(x, zSize - 1 - z); } },
		{ FaceData::RIGHT,  [            ](int, int y, int z) { return QPoint(z, y); } },
		{ FaceData::BACK,   [xSize       ](int x, int y, int) { return QPoint(xSize - 1 - x, y); } },
		{ FaceData::BOTTOM, [xSize, zSize](int x, int, int z) { return QPoint(xSize - 1 - x, zSize - 1 - z); } },
		{ FaceData::LEFT,   [       zSize](int, int y, int z) { return QPoint(zSize - 1 - z, y); } }
	};

	QMap< FaceData::FaceIndex, QImage > faceImages {
		{ FaceData::FRONT,  images[data.front().face()]  },
		{ FaceData::TOP,    images[data.top().face()]    },
		{ FaceData::RIGHT,  images[data.right().face()]  },
		{ FaceData::BACK,   images[data.back().face()]   },
		{ FaceData::BOTTOM, images[data.bottom().face()] },
		{ FaceData::LEFT,   images[data.left().face()]   }
	};

	const QImage& templateImage = images["template"];

	QImage templateOutput;

	QMetaObject::invokeMethod(exporter, "setStatusMessage", Qt::QueuedConnection, Q_ARG(QString, tr("Starting...")));
	QMetaObject::invokeMethod(exporter, "setProgress", Qt::QueuedConnection, Q_ARG(qreal, m_exportStart));

	int count = 0;
	int total = xSize * ySize * zSize;

	for (int x = 0; x < xSize; ++x)
	{
		if (exporter->m_canceled) break;

		for (int y = 0; y < ySize; ++y)
		{
			if (exporter->m_canceled) break;

			for (int z = 0; z < zSize; ++z)
			{
				if (exporter->m_canceled) break;

				FaceData::FaceIndex mainIndex = FaceData::INVALID;
				QPoint mainPoint;

				for (const auto& face : data.faces())
				{
					if (face.enabled() && visible[face.index()](x, y, z))
					{
						auto pos2d = translate[face.index()](x, y, z);

						if (pos2d.x() < face.horizontalCount() && pos2d.y() < face.verticalCount())
						{
							if (mainIndex == FaceData::INVALID)
							{
								mainIndex = face.index();
								mainPoint = pos2d;
							}

							QMetaObject::invokeMethod(exporter, "setStatusMessage", Qt::QueuedConnection,
													  Q_ARG(QString, tr("Processing face '%1' x:%2, y:%3!").arg(face.text()).arg(pos2d.x()).arg(pos2d.y())));

							if (templateOutput.isNull())
							{
								templateOutput = templateImage.copy();
							}

							const QImage& faceImage = faceImages[face.index()];
							QRect source(QPoint(face.faceRect().width() * pos2d.x(), face.faceRect().height() * pos2d.y()), face.faceRect().size());

							QPainter painter(&templateOutput);
							painter.drawImage(face.faceRect().topLeft(), faceImage, source, Qt::NoFormatConversion);
						}
					}
				}

				if (mainIndex != FaceData::INVALID && !templateOutput.isNull())
				{
					QDir path = destination.toLocalFile();
					QString file = QString("%5-%1%2%3-%4-%2,%3.png").arg(mainIndex).arg(mainPoint.x() + 1).arg(mainPoint.y() + 1).arg(data.faces()[mainIndex].text()).arg("waifu2ugc");

					QMetaObject::invokeMethod(exporter, "setStatusMessage", Qt::QueuedConnection,
											  Q_ARG(QString, tr("Saving %1...").arg(file)));

					templateOutput.save(path.filePath(file));
					templateOutput = QImage();
				}

				++count;

				QMetaObject::invokeMethod(exporter, "setProgress", Qt::QueuedConnection, Q_ARG(qreal, m_exportStart + count * m_exportTotal / total));
			}
		}
	}

	if (!exporter->m_canceled)
	{
		QMetaObject::invokeMethod(exporter, "setStatusMessage", Qt::QueuedConnection, Q_ARG(QString, tr("Completed!")));
		QMetaObject::invokeMethod(exporter, "setProgress", Qt::QueuedConnection, Q_ARG(qreal, m_exportStart + m_exportTotal));
	}
	else
	{
		QMetaObject::invokeMethod(exporter, "setStatusMessage", Qt::QueuedConnection, Q_ARG(QString, tr("Canceled while exporting.")));
		QMetaObject::invokeMethod(exporter, "emitAborted", Qt::QueuedConnection);
	}
}

// Candidate for refactoring.
// Shameless abuse of QQmlFile (undocumented) to deliver the same QML behavior for loading Urls
void TemplateExporter::preloadImages() {
	setStatusMessage(tr("Preloading images..."));
	setProgress(m_preloadingStart);

	QHash<QString, QUrl> urls {
		{ "template",  m_data.templateUrl() },

		{ m_frontFace->face() , m_frontFace->faceImageUrl()  },
		{ m_topFace->face()   , m_topFace->faceImageUrl()    },
		{ m_rightFace->face() , m_rightFace->faceImageUrl()  },
		{ m_backFace->face()  , m_backFace->faceImageUrl()   },
		{ m_bottomFace->face(), m_bottomFace->faceImageUrl() },
		{ m_leftFace->face()  , m_leftFace->faceImageUrl()   }
	};

	QHash<QString, bool> enabled {
		{ "template",  true },

		{ m_frontFace->face() , m_frontFace->faceEnabled()  },
		{ m_topFace->face()   , m_topFace->faceEnabled()    },
		{ m_rightFace->face() , m_rightFace->faceEnabled()  },
		{ m_backFace->face()  , m_backFace->faceEnabled()   },
		{ m_bottomFace->face(), m_bottomFace->faceEnabled() },
		{ m_leftFace->face()  , m_leftFace->faceEnabled()   }
	};

	QHash<QString, const char*> callbacks {
		{ "template",  SLOT(templateImageFinished()) },

		{ m_frontFace->face() , SLOT(frontImageFinished())  },
		{ m_topFace->face()   , SLOT(topImageFinished())    },
		{ m_rightFace->face() , SLOT(rightImageFinished())  },
		{ m_backFace->face()  , SLOT(backImageFinished())   },
		{ m_bottomFace->face(), SLOT(bottomImageFinished()) },
		{ m_leftFace->face()  , SLOT(leftImageFinished())   }
	};

	QQmlEngine* engine = QQmlEngine::contextForObject(this)->engine();

	bool hasError = false;

	if (engine != nullptr)
	{
		for (auto it = urls.begin(); it != urls.end(); ++it)
		{
			m_loaderReady[it.key()] = !enabled[it.key()];

			if (enabled[it.key()])
			{
				auto& filePtr = m_loaders[it.key()];

				if (filePtr.isNull())
				{
					filePtr.reset(new QQmlFile());
				}

				QQmlFile* file = filePtr.get();

				if (QQmlFile::isSynchronous(it.value()))
				{
					file->load(engine, it.value());

					if (file->isLoading())
					{
						// Should never happen
						file->connectFinished(this, callbacks[it.key()]);
					}
					else if (file->isReady())
					{
						QTimer::singleShot(0, this, callbacks[it.key()]);
					}
					else if (file->isError() || file->isNull())
					{
						emitError(tr("Error loading image from:\r\n%1").arg(it.value().toString()));

						hasError = true;
						break;
					}
				}
				else
				{
					file->load(engine, it.value());
					file->connectFinished(this, callbacks[it.key()]);

					if (file->isReady())
					{
						QTimer::singleShot(0, this, callbacks[it.key()]);
					}
					else if (file->isError() || file->isNull())
					{
						emitError(tr("Error downloading image for:\r\n%1").arg(it.value().toString()));

						hasError = true;
						break;
					}
				}
			}
			else
			{
				QTimer::singleShot(0, this, callbacks[it.key()]);
			}
		}
	}
	else
	{
		emitError(tr("Failed to get a pointer to the QML Engine."));
		hasError = true;
	}

	if (hasError)
	{
		setBusy(false);
	}
}

void TemplateExporter::checkLoaders() {
	if (!m_canceled)
	{
		long count = std::count_if(m_loaderReady.begin(), m_loaderReady.end(), [](bool ready){ return ready; });

		setStatusMessage(tr("%1/%2 images loaded...").arg(count).arg(m_loaderReady.count()));
		setProgress(m_preloadingStart + count * m_preloadingTotal / m_loaderReady.count());

		if (count == m_loaderReady.count())
		{
			setProgress(m_preloadingStart + m_preloadingTotal);
			startProcessing();
		}
	}
	else
	{
		setStatusMessage(tr("Canceled while preloading images."));
		setBusy(false);

		emitAborted();
	}
}

// Candidates for refactoring.
void TemplateExporter::imageLoaded(const QString& owner, QQmlFile* file)
{
	bool hasError = false;

	if (file != nullptr)
	{
		if (file->isReady())
		{
			m_loaderReady[owner] = true;
		}
		else if (file->isError())
		{
			emitError(tr("Error downloading image from:\r\n%1.").arg(file->url().toString()));
			hasError = true;
		}
		else
		{
			emitError(tr("Invalid state: QML File for '%1' is not ready nor has error.").arg(owner));
			hasError = true;
		}
	}
	else
	{
		emitError(tr("Invalid state: QML File pointer for '%1' is null.").arg(owner));
		hasError = true;
	}

	if (m_canceled)
	{
		setStatusMessage(tr("Canceled while preloading images."));
		setBusy(false);

		emitAborted();
	}
	else if (!hasError)
	{
		checkLoaders();
	}
	else
	{
		setBusy(false);
	}
}

void TemplateExporter::templateImageFinished()
{
	imageLoaded("template", m_loaders["template"].get());
}

void TemplateExporter::frontImageFinished()
{
	if (m_frontFace->faceEnabled())
	{
		imageLoaded(m_frontFace->face(), m_loaders[m_frontFace->face()].get());
	}
}

void TemplateExporter::topImageFinished()
{
	if (m_topFace->faceEnabled())
	{
		imageLoaded(m_topFace->face(), m_loaders[m_topFace->face()].get());
	}
}

void TemplateExporter::rightImageFinished()
{
	if (m_rightFace->faceEnabled())
	{
		imageLoaded(m_rightFace->face(), m_loaders[m_rightFace->face()].get());
	}
}

void TemplateExporter::backImageFinished()
{
	if (m_backFace->faceEnabled())
	{
		imageLoaded(m_backFace->face(), m_loaders[m_backFace->face()].get());
	}
}

void TemplateExporter::bottomImageFinished()
{
	if (m_bottomFace->faceEnabled())
	{
		imageLoaded(m_bottomFace->face(), m_loaders[m_bottomFace->face()].get());
	}
}

void TemplateExporter::leftImageFinished()
{
	if (m_leftFace->faceEnabled())
	{
		imageLoaded(m_leftFace->face(), m_loaders[m_leftFace->face()].get());
	}
}
