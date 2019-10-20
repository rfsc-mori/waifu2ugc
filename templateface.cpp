#include "templateface.h"

TemplateFace::TemplateFace(const QString& face, FaceData::FaceIndex index, const QString& text, QObject* parent) : QObject(parent)
{
	m_data.face() = face;
	m_data.index() = index;
	m_data.text() = text;
}

QString TemplateFace::face() const
{
	return m_data.face();
}

int TemplateFace::index() const {
	return m_data.index();
}

QString TemplateFace::text() const {
	return m_data.text();
}

bool TemplateFace::faceEnabled() const
{
	return m_data.enabled();
}

void TemplateFace::setFaceEnabled(bool faceEnabled)
{
	if (m_data.enabled() != faceEnabled)
	{
		m_data.enabled() = faceEnabled;
		emit faceEnabledChanged();
	}
}

QRect TemplateFace::faceRect() const
{
	return m_data.faceRect();
}

void TemplateFace::setFaceRect(const QRect& faceRect)
{
	if (m_data.faceRect() != faceRect)
	{
		m_data.faceRect() = faceRect;
		emit faceRectChanged();
	}
}

int TemplateFace::horizontalCount() const
{
	return m_data.horizontalCount();
}

void TemplateFace::setHorizontalCount(int horizontalCount)
{
	if (m_data.horizontalCount() != horizontalCount)
	{
		m_data.horizontalCount() = horizontalCount;
		emit horizontalCountChanged();
	}
}

int TemplateFace::verticalCount() const
{
	return m_data.verticalCount();
}

void TemplateFace::setVerticalCount(int verticalCount)
{
	if (m_data.verticalCount() != verticalCount)
	{
		m_data.verticalCount() = verticalCount;
		emit verticalCountChanged();
	}
}

QUrl TemplateFace::faceImageUrl() const
{
	return m_data.faceImageUrl();
}

void TemplateFace::setFaceImageUrl(const QUrl& faceImageUrl)
{
	if (m_data.faceImageUrl() != faceImageUrl)
	{
		m_data.faceImageUrl() = faceImageUrl;
		emit faceImageUrlChanged();
	}
}

bool TemplateFace::resizeSource() const
{
	return m_data.resizeSource();
}

void TemplateFace::setResizeSource(bool resizeSource)
{
	if (m_data.resizeSource() != resizeSource)
	{
		m_data.resizeSource() = resizeSource;
		emit resizeSourceChanged();
	}
}

bool TemplateFace::preserveAspectRatio() const
{
	return m_data.preserveAspectRatio();
}

void TemplateFace::setPreserveAspectRatio(bool preserveAspectRatio)
{
	if (m_data.preserveAspectRatio() != preserveAspectRatio)
	{
		m_data.preserveAspectRatio() = preserveAspectRatio;
		emit preserveAspectRatioChanged();
	}
}

TemplateFace::AspectRatioAction TemplateFace::aspectRatioAction() const
{
	return static_cast<AspectRatioAction>(m_data.aspectRatioAction());
}

void TemplateFace::setAspectRatioAction(AspectRatioAction aspectRatioAction)
{
	if (m_data.aspectRatioAction() != aspectRatioAction)
	{
		m_data.aspectRatioAction() = aspectRatioAction;
		emit aspectRatioActionChanged();
	}
}

QRect TemplateFace::fitRect() const
{
	return m_data.fitRect();
}

void TemplateFace::setFitRect(const QRect& fitRect)
{
	if (m_data.fitRect() != fitRect)
	{
		m_data.fitRect() = fitRect;
		emit fitRectChanged();
	}
}

QRect TemplateFace::cropRect() const
{
	return m_data.cropRect();
}

void TemplateFace::setCropRect(const QRect& cropRect)
{
	if (m_data.cropRect() != cropRect)
	{
		m_data.cropRect() = cropRect;
		emit cropRectChanged();
	}
}

FaceData TemplateFace::copyData() const
{
	return m_data;
}
