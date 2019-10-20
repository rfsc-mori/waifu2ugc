#ifndef TEMPLATEDATA_H
#define TEMPLATEDATA_H

#include <QUrl>

class TemplateData
{
public:
	QUrl& templateUrl()				{ return m_templateUrl; }
	const QUrl& templateUrl() const { return m_templateUrl; }

private:
	QUrl m_templateUrl;
};

#endif // TEMPLATEDATA_H
