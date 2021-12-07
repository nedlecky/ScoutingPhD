#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

int Rdelta(int x)
{
	int r=rand()%(x*2+1) - x;
	return r;
}
struct ChordDefinitions
{
	char* ref;
	char* desc;
	char* notes;
};

int halfStep[]={
	0,2,4,5,7,9,11,12};

ChordDefinitions chordef[]={
	{"C",		"Major Triad",						"R,3,5"},
	{"Cm",		"Minor Triad",						"R,b3,5"},
	{"C+5",		"Augmented Triad",					"R,3,#5"},
	{"C-5",		"Lowered Fifth Triad",				"R,3,b5"},
	{"Cdim",	"Diminished Triad",					"R,b3,b5"},
	{"Cmaj7",	"Major Seventh Chord",				"R,3,5,7"},
	{"C7",		"Dominant Seventh Chord",			"R,3,5,b7"},
	{"Cm7",		"Minor Seventh Chord",				"R,b3,5,b7"},
	{"C6",		"Major Sixth Chord",				"R,3,5,6"},
	{"Cm6",		"Minor Sixth Chord",				"R,b3,5,6"},
	{"Cdim7",	"Diminished Seventh Chord",			"R,b3,b5,bb7"},
	{"Cm7-5",	"Minor Seventh Lowered Fifth Chord","R,b3,b5,b7"},
	{"C7+5",	"Seventh Augmented Fifth Chord",	"R,3,#5,b7"},
	{"C7-5",	"Seventh Lowered Fifth Chord",		"R,3,b5,b7"},
	{"C7sus4",	"Seventh Suspended Fourth Chord",	"R,4,5,b7"},

	// Unsure
	{"C7sus",	"guess at 7sus",		"R,3,b7"},
	{"Csus",	"guess at sus",			"R,5"},
	{NULL,		NULL,						NULL}
	};

void ShowChordDefinitions(void)
{
	int i=0;
	printf("%10s %30s %15s\n","CHORD","DESCRIPTION","NOTES");
	while(chordef[i].ref)
	{
		printf("%10s %30s %15s\n",
			chordef[i].ref,chordef[i].desc,chordef[i].notes);
		i++;
	}
}

int Tone2HalfSteps(int t)
{
	if(t<0) t=0;
	if(t>8) t=8;
	return halfStep[t];
}

// Examples: G4... Ab3... F#3...
int Note2MIDINum(char* notestr)
{
printf("Convert %s ",notestr);
	if(notestr==NULL) return -1;

	// Get Key
	char* cp=notestr;
	char c=*cp++;
	if(c<'A' || c>'G') return -1;

	// Trick: A is like H, B is like I
	if(c<'C') c+=7;

	// C0 is 24 MIDI
	int note=halfStep[c-'C']+24;

	// Sharp or Flat?
	if(*cp)
	{
		c=*cp;
		if(c=='#')
		{
			note++;
			cp++;
		}
		if(c=='b')
		{
			note--;
			cp++;
		}
	}

	// Octave Specification
	if(*cp)
	{
		c=*cp;
		int fNeg=0;
		if(c=='-')
		{
			fNeg=1;
			cp++;
			if(*cp==0) return -1;
			c=*cp;
		}
		if(c<'0' || c>'9') return -1;
		int octave=c-'0';
		if(fNeg) octave=-octave;
		note+=octave*12;
	}

	if(note<0 || note>127) return -1;

	return note;
}

class Event
{
protected:
	int time;
	int velocity;
public:
	Event(int t=0,int v=60);
	~Event();
	void SetTime(int t) {time=t;}
	void SetVelocity(int v) {velocity=v;}
	void BumpTime(int t) {time+=t;}
	virtual int Play(FILE* fp=NULL)=0;
};
Event::Event(int t,int v)
{
	SetTime(t);
	SetVelocity(v);
}
Event::~Event()
{
}

enum ePlaystyle {pNormal=0,pArpeggiate};
class Chord : public Event
{
private:
	char* name;
	ePlaystyle style;
	int octave;
	int position;
	int duration;
	int nAddons;
public:
	Chord(char* chordname="C4",int octave=4,int time=0,int dur=100,int pos=0,int add=0);
	~Chord();
	void SetName(char* chordname);
	void SetDuration(int d) {duration=d;}
	void SetOctave(int oct) {octave=oct;}
	void SetPosition(int pos) {position=pos;}
	void SetAddons(int add) {nAddons=add;}
	int Play(FILE* fp=NULL);
};
Chord::Chord(char* chordname,int octave,int time,int dur,int pos,int add)
{
	name=NULL;
	SetOctave(octave);
	SetPosition(pos);
	SetName(chordname);
	SetTime(time);
	SetDuration(dur);
	SetAddons(add);
}
Chord::~Chord()
{
	if(name) delete name;
}
void Chord::SetName(char* chordname)
{
	if(name)
	{
		delete name;
		name=NULL;
	}
	if(chordname)
		name=strdup(chordname);
}
int Chord::Play(FILE* fp)
{
	// Get Key
	char key[32];
	char* cp=key;
	char* chord=name;
	*cp++=*chord++;
	if(*chord=='#' || *chord=='b')
	{
		*cp++=*chord++;
	}
	sprintf(cp,"%d",octave);

	int* MIDInotes=new int[4+nAddons];

	// find root in MIDI counts
	int numNotes=0;
	MIDInotes[numNotes++]=Note2MIDINum(key);
	
	// knock out bass note if included
	int fBassNote=0;
	char* pos=strchr(chord,'/');
	if(pos)
	{
		fBassNote=1;
		*pos=0;
	}
	
	// lookup chord and find extra notes
	int found=0;
	int i=0;
	int chordIndex=-1;
	while(chordef[i].ref && found==0)
	{
		if(!strcmp(chordef[i].ref+1,chord))
		{
			chordIndex=i;
			found=1;
		}
		i++;
	}

	// found the chord; extract notelist
	if(chordIndex>=0)
	{
		char* cp=chordef[chordIndex].notes+2;
		while(*cp)
		{
			int note=0;
			// sharped or flatted?
doublesharpflat:
			if(*cp=='#')
			{
				note++;
				cp++;
				goto doublesharpflat;
			}
			if(*cp=='b')
			{
				note--;
				cp++;
				goto doublesharpflat;
			}
			note+=Tone2HalfSteps(*cp-'0'-1);
			cp++;
			MIDInotes[numNotes++]=note+MIDInotes[0];
			if(*cp==',') cp++;
		}
	}

	// inversions
	for(i=0; i<position-1; i++)
		MIDInotes[i]+=12;

	// addons
	for(i=0; i<nAddons; i++)
		MIDInotes[numNotes++]=MIDInotes[i]+12;


	printf("%s p=%d a=%d NOTES: ",name,position,nAddons);
	for(i=0; i<numNotes; i++)
		printf("%d ",MIDInotes[i]);

	if(fp)
	{
	for(i=0; i<numNotes; i++)
		fprintf(fp,"\"ON\",%d,%d,%d\n",time+Rdelta(25),MIDInotes[i],velocity);
	for(i=0; i<numNotes; i++)
		fprintf(fp,"\"OFF\",%d,%d\n",time+duration+Rdelta(25),MIDInotes[i]);
	}
	if(fBassNote)
	{
		*pos='\\';
		int bassnote=Note2MIDINum(pos+1);
		printf("bass note %d",bassnote);
		if(fp)
		{
			fprintf(fp,"\"ON\",%d,%d,%d\n",time+Rdelta(25),bassnote,velocity);
			fprintf(fp,"\"ON\",%d,%d,%d\n",time+Rdelta(25),bassnote-12,velocity);
			fprintf(fp,"\"OFF\",%d,%d\n",time+duration+Rdelta(25),bassnote);
			fprintf(fp,"\"OFF\",%d,%d\n",time+duration+Rdelta(25),bassnote-12);
		}
	}
	printf("\n");
	delete MIDInotes;
	return 0;
}

class Track
{
private:
	int nEvents;
	int nAllocated;
	Event** events;
public:
	Track();
	~Track();
	int AddEvent(Event* e);
	int Play(FILE* fp);
};
Track::Track()
{
	nEvents=0;
	nAllocated=0;
	events=NULL;
}
Track::~Track()
{
	if(events)
	{
		for(int i=0; i<nEvents; i++)
			delete events[i];
		delete events;
	}
}
int Track::AddEvent(Event* e)
{
	if(e==NULL) return 1;

	if(nEvents+1>nAllocated)
	{
		Event** old=events;
		nAllocated+=10;
		events=new Event*[nAllocated];
		for(int i=0; i<nEvents; i++)
			events[i]=old[i];
		delete old;
	}
	events[nEvents++]=e;

	return 0;
}
int Track::Play(FILE* fp)
{
	for(int i=0; i<nEvents; i++)
		events[i]->Play(fp);
	return 0;
}

int qnote=1000;
int time=1000;
int noteLen;
int WholeNote(void)
{
	int t=time;
	time+=4*qnote;
	noteLen=4*qnote;
	return t;
}
int HalfNote(void)
{
	int t=time;
	time+=2*qnote;
	noteLen=2*qnote;
	return t;
}
int NoteLen(void)
{
	return noteLen;
}
int main()
{
	printf("Composer\n");
	ShowChordDefinitions();

	Track t1;
	
	
	// Home
	t1.AddEvent(new Chord("G/G2",     2, HalfNote(),NoteLen(),1,0));
	t1.AddEvent(new Chord("G/F#2",    2, HalfNote(),NoteLen(),1,0));
	t1.AddEvent(new Chord("G/E2",     2, HalfNote(),NoteLen(),1,0));
	t1.AddEvent(new Chord("G/D2",     2, HalfNote(),NoteLen(),1,0));
	t1.AddEvent(new Chord("C/C2",     2, HalfNote(),NoteLen(),1,0));
	t1.AddEvent(new Chord("C/B2",     2, HalfNote(),NoteLen(),1,0));
	t1.AddEvent(new Chord("Am7/A2",   2, HalfNote(),NoteLen(),1,0));
	t1.AddEvent(new Chord("C/D2",     2, HalfNote(),NoteLen(),1,0));
	t1.AddEvent(new Chord("Gsus/G2",  2, HalfNote(),NoteLen(),1,0));
	t1.AddEvent(new Chord("G/G2",     2, HalfNote(),NoteLen(),1,0));
	t1.AddEvent(new Chord("Esus/E2",  2, HalfNote(),NoteLen(),1,0));
	t1.AddEvent(new Chord("Em/E2",    2, HalfNote(),NoteLen(),1,0));
	t1.AddEvent(new Chord("Am7/A2",   2, WholeNote(),NoteLen(),1,0));
	t1.AddEvent(new Chord("B7sus/B2", 2, HalfNote(),NoteLen(),1,0));
	t1.AddEvent(new Chord("B7/B2",    2, HalfNote(),NoteLen(),1,0));
	t1.AddEvent(new Chord("Em/E2",    2, WholeNote(),NoteLen(),1,0));
	t1.AddEvent(new Chord("G7/D2",    2, WholeNote(),NoteLen(),1,0));
	t1.AddEvent(new Chord("C6/C2",    2, WholeNote(),NoteLen(),1,0));
	t1.AddEvent(new Chord("Bm/D2",    2, WholeNote(),NoteLen(),1,0));
	t1.AddEvent(new Chord("G/G2",     2, WholeNote(),NoteLen(),1,0));

	/*
	t1.AddEvent(new Chord("Am", 2, 100,950,3,1));
	t1.AddEvent(new Chord("G6", 2,1100,950,4,0));
	t1.AddEvent(new Chord("Bm", 2,2100,950,1,1));
	t1.AddEvent(new Chord("F#m",2,3100,950,1,1));
	t1.AddEvent(new Chord("C",  2,4100,950,3,1));
	t1.AddEvent(new Chord("D",  2,5100,950,2,1));
	t1.AddEvent(new Chord("F",  2,6100,950,1,1));
	t1.AddEvent(new Chord("Em", 2,71`00,950,1,1));
	*/

	
	/*
	t1.AddEvent(new Chord("C", 3,  10, 950,1,0));
	t1.AddEvent(new Chord("F", 2,1000, 950,3,0));
	t1.AddEvent(new Chord("G", 2,2000, 950,3,0));
	t1.AddEvent(new Chord("F", 2,3000, 950,3,0));
	t1.AddEvent(new Chord("C", 3,4000, 950,1,0));
	t1.AddEvent(new Chord("G", 2,5000, 950,2,0));
	t1.AddEvent(new Chord("F", 2,6000,1950,2,0));

  */

	FILE* fp=fopen("d:\\research\\StreamPlayer\\stream.dat","w");
	t1.Play(fp);
	fclose(fp);

	return 0;
}