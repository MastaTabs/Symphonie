#include <exec/types.h>
#include <proto/exec.h>
// #include <proto/dos.h>

struct Library *IntuitionBase;
struct Library *GraphicsBase;
struct DosLibrary *DOSBase;
struct Library *AslBase;
struct Library *LayersBase;
struct Library *GadToolsBase;
struct Library *ReqToolsBase;
struct Library *CamdBase;
struct Library *XpkBase;

void CloseLibs(void) {

	if(IntuitionBase)
		CloseLibrary(IntuitionBase);
	if(GraphicsBase)
		CloseLibrary(GraphicsBase);
	if(DOSBase)
		CloseLibrary((struct Library *)DOSBase);
	if(AslBase)
		CloseLibrary(AslBase);
	if(LayersBase)
		CloseLibrary(LayersBase);
	if(GadToolsBase)
		CloseLibrary(GadToolsBase);
	if(ReqToolsBase)
		CloseLibrary(ReqToolsBase);
	if(CamdBase)
		CloseLibrary(CamdBase);
	if(XpkBase)
		CloseLibrary(XpkBase);

}

BOOL OpenLibs(void) {
	BOOL ret = TRUE;

	IntuitionBase = OpenLibrary("intuition.library", 0);
	GraphicsBase = OpenLibrary("graphics.library", 0);
	DOSBase = (struct DosLibrary *)OpenLibrary("dos.library", 0);
	AslBase = OpenLibrary("asl.library", 0);
	LayersBase = OpenLibrary("layers.library", 0);
	GadToolsBase = OpenLibrary("gadtools.library", 0);
	ReqToolsBase = OpenLibrary("reqtools.library", 0);
	CamdBase = OpenLibrary("camd.library", 0);			/* optional */
	XpkBase = OpenLibrary("xpk.library", 0);			/* optional */

	// Printf("test 0x%lx\n", IntuitionBase);

	if(!IntuitionBase)
		ret = FALSE;
	if(!GraphicsBase)
		ret = FALSE;
	if(!DOSBase)
		ret = FALSE;
	if(!AslBase)
		ret = FALSE;
	if(!LayersBase)
		ret = FALSE;
	if(!GadToolsBase)
		ret = FALSE;
	if(!ReqToolsBase)
		ret = FALSE;

	if(ret == FALSE)
		CloseLibs();

	return ret;
}
