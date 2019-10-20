#ifndef TEMPLATEFACE_H
#define TEMPLATEFACE_H

#include <QObject>
#include <QString>
#include <QRect>
#include <QUrl>

#include "facedata.h"

class TemplateFace : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QString face READ face CONSTANT)
	Q_PROPERTY(int index READ index CONSTANT)
	Q_PROPERTY(QString text READ text CONSTANT)
	Q_PROPERTY(bool faceEnabled READ faceEnabled WRITE setFaceEnabled NOTIFY faceEnabledChanged)
	Q_PROPERTY(QRect faceRect READ faceRect WRITE setFaceRect NOTIFY faceRectChanged)
	Q_PROPERTY(int horizontalCount READ horizontalCount WRITE setHorizontalCount NOTIFY horizontalCountChanged)
	Q_PROPERTY(int verticalCount READ verticalCount WRITE setVerticalCount NOTIFY verticalCountChanged)
	Q_PROPERTY(QUrl faceImageUrl READ faceImageUrl WRITE setFaceImageUrl NOTIFY faceImageUrlChanged)
	Q_PROPERTY(bool resizeSource READ resizeSource WRITE setResizeSource NOTIFY resizeSourceChanged)
	Q_PROPERTY(bool preserveAspectRatio READ preserveAspectRatio WRITE setPreserveAspectRatio NOTIFY preserveAspectRatioChanged)
	Q_PROPERTY(AspectRatioAction aspectRatioAction READ aspectRatioAction WRITE setAspectRatioAction NOTIFY aspectRatioActionChanged)
	Q_PROPERTY(QRect fitRect READ fitRect WRITE setFitRect NOTIFY fitRectChanged)
	Q_PROPERTY(QRect cropRect READ cropRect WRITE setCropRect NOTIFY cropRectChanged)

public:
	enum AspectRatioAction {
		FIT = 0,
		CROP = 1
	};
	Q_ENUM(AspectRatioAction)

	explicit TemplateFace(QObject* parent = nullptr) = delete;
	explicit TemplateFace(const QString& face, FaceData::FaceIndex index, const QString& text, QObject* parent = nullptr);

	QString face() const;
	int index() const;
	QString text() const;

	bool faceEnabled() const;
	void setFaceEnabled(bool faceEnabled);

	QRect faceRect() const;
	void setFaceRect(const QRect& faceRect);

	int horizontalCount() const;
	void setHorizontalCount(int horizontalCount);

	int verticalCount() const;
	void setVerticalCount(int verticalCount);

	QUrl faceImageUrl() const;
	void setFaceImageUrl(const QUrl& faceImageUrl);

	bool resizeSource() const;
	void setResizeSource(bool resizeSource);

	bool preserveAspectRatio() const;
	void setPreserveAspectRatio(bool preserveAspectRatio);

	AspectRatioAction aspectRatioAction() const;
	void setAspectRatioAction(AspectRatioAction aspectRatioAction);

	QRect fitRect() const;
	void setFitRect(const QRect& fitRect);

	QRect cropRect() const;
	void setCropRect(const QRect& cropRect);

	FaceData copyData() const;

signals:
	void faceChanged();

	void faceEnabledChanged();

	void faceRectChanged();

	void horizontalCountChanged();
	void verticalCountChanged();

	void faceImageUrlChanged();

	void resizeSourceChanged();
	void preserveAspectRatioChanged();

	void aspectRatioActionChanged();

	void fitRectChanged();
	void cropRectChanged();

private:
	FaceData m_data;
};

#endif // TEMPLATEFACE_H
