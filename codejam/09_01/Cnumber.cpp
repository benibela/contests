#include <QtCore>
#include <iostream>
const int dx[4]={0,0,-1,1};
const int dy[4]={-1,1,0,0};
bool newsolbetter (const QString& old, const QString& ne){
	if (old.length()<ne.length()) return false;
	else if (old.length()>ne.length()) return true;
	else if (old>ne) return true;
	else return false;
}
int main (){	
	QMap<int,QString> pos[25][25];
	char map[25][25];
	int testcases;
	scanf("%i\n", &testcases);
	for (int TC=1; TC<=testcases;TC++){
		for (int i=0;i<25;i++)
			for (int j=0;j<25;j++) {
				map[i][j]='\0';
				pos[i][j].clear();
			}
		int wide; int queries;
		QList<int> queryo;
		QSet<int> query;
		QMap<int, QString> res;
		scanf("%i %i\n",&wide,&queries);
		for (int i=1;i<=wide;i++)
			scanf("%s\n",&map[i][1]);
		for (int i=0;i<queries;i++) {
			int q;
			scanf("%i",&q);
			queryo << q;
			query << q;
		}
		scanf("\n");
		//for (int i=0;i<wide;i++) printf("check: %s\n",&map[i][0]);
		for (int i=1;i<=wide;i++)
			for (int j=1;j<=wide;j++) 
				if (map[i][j]>='0' && map[i][j]<='9') {
					pos[i][j].insert((int)(map[i][j]-'0'),QChar(map[i][j]));			
					if (query.contains((int)(map[i][j]-'0')) &&
						!res.contains((int)(map[i][j]-'0'))) 
						res.insert(map[i][j]-'0',QChar(map[i][j]));
				}
		while (res.size()!=query.size()) {
			//fprintf(stderr,"TEST\n");
			for (int i=1;i<=wide;i++)
				for (int j=1;j<=wide;j++) 
					if (map[i][j]=='+' || map[i][j]=='-') {
						for (int k=0;k<4;k++) {
							//fprintf(stderr,"  %i %i %i\n",i,j,k);
							QMap<int,QString>::iterator end=pos[i+dx[k]][j+dy[k]].end();
							for (QMap<int,QString>::iterator it=pos[i+dx[k]][j+dy[k]].begin(); it!=end; it++){
								int myval=it.key();
								if (myval > 1500 || myval<-1500) continue;
								if (map[i][j]=='-') myval-=2*(map[i+dx[k]][j+dy[k]]-'0');
								if (!pos[i][j].contains(myval) ||
									(newsolbetter(pos[i][j].value(myval),it.value()))) {
									pos[i][j].insert(myval,it.value());
								}
							}
						}
					}
			//fprintf(stderr,"TEST++\n");

			for (int i=1;i<=wide;i++)
				for (int j=1;j<=wide;j++) 
					if (map[i][j]>='0' && map[i][j]<='9') {
						for (int k=0;k<4;k++) {
							//fprintf(stderr,"   %i %i %i\n",i,j,k);
							QMap<int,QString>::iterator end=pos[i+dx[k]][j+dy[k]].end();
							for (QMap<int,QString>::iterator it=pos[i+dx[k]][j+dy[k]].begin(); it!=end; it++){
								int myval=(int)(map[i][j]-'0')+it.key();
								if (myval > 1500 || myval<-1500) continue;
								QString news = QString(QChar(map[i][j]))+
												QString(QChar(map[i+dx[k]][j+dy[k]]))+it.value();
								if (!pos[i][j].contains(myval) ||
									(newsolbetter(pos[i][j].value(myval),news))) {
									pos[i][j].insert(myval,news);
									//fprintf (stderr,"DEB: %i<-%s\n",myval,qPrintable(news));
									if (query.contains(myval) &&
										(!res.contains(myval) || (newsolbetter(res.value(myval),news)))){
										res.insert(myval,news);
										//fprintf (stderr,"DEBUG: %i<-%s\n",myval,qPrintable(news));
									}
								}
							}
						}
					}
		}
		printf("Case #%i:\n",TC);
		for (int i=0;i<queryo.size();i++)
			printf("%s\n",qPrintable(res.value(queryo[i])));
	}
	//std::cout << "test\n";
	return 0;
}
