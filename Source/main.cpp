#include "App.h"

using namespace Leadwerks;

void DebugErrorHook(char* c)
{
	int n=0;//<-- Add a breakpoint here to catch errors
}

int main(int argc,const char *argv[])
{
	//Load saved settings
	std::string settingsfile = std::string(argv[0]);
	settingsfile = FileSystem::StripAll(settingsfile);
	if (String::Right(settingsfile, 6) == ".debug") settingsfile = String::Left(settingsfile, settingsfile.length() - 6);
	System::AppName = settingsfile;
	std::string settingsdir = FileSystem::GetAppDataPath();
#ifdef __linux__
	settingsdir = settingsdir + "/." + String::Lower(settingsfile);
#else
	settingsdir = settingsdir + "/" + settingsfile;
#endif
	if (FileSystem::GetFileType(settingsdir) == 0) FileSystem::CreateDir(settingsdir);
	settingsfile = settingsdir + "/" + settingsfile + ".cfg";
	System::LoadSettings(settingsfile);
	
	//Set program path
	System::AppPath = FileSystem::ExtractDir(argv[0]);
	
	//Load command-line parameters
	System::ParseCommandLine(argc, argv);
	
	//Enable Lua sandboxing
	if (String::Int(System::GetProperty("sandbox")) != 0) Interpreter::sandboxmode = true;
	
	//Switch directory
	std::string gamepack = System::GetProperty("game");
	if (gamepack != "")
	{
		Package* package = Package::Load(gamepack);
		if (!package) return 1;
	}
	
	//Add debug hook for catching errors
	Leadwerks::System::AddHook(System::DebugErrorHook,(void*)DebugErrorHook);
	
    //Load any zip files in main directory
    Leadwerks::Directory* dir = Leadwerks::FileSystem::LoadDir(".");
    if (dir)
    {
        for (int i=0; i<dir->files.size(); i++)
        {
            std::string file = dir->files[i];
			std::string ext = Leadwerks::String::Lower(Leadwerks::FileSystem::ExtractExt(file));
            if (ext=="zip" || ext=="pak")
            {
                Leadwerks::Package::Load(file);
            }
        }
        delete dir;
    }
	
#ifdef DEBUG
	std::string debuggerhostname = System::GetProperty("debuggerhostname");
	if (debuggerhostname!="")
	{
		//Connect to the debugger
		int debuggerport = String::Int(System::GetProperty("debuggerport"));
		if (!Interpreter::Connect(debuggerhostname,debuggerport))
		{
			Print("Error: Failed to connect to debugger with hostname \""+debuggerhostname+"\" and port "+String(debuggerport)+".");
			return false;
		}
		Print("Successfully connected to debugger.");
		std::string breakpointsfile = System::GetProperty("breakpointsfile");
		if (breakpointsfile!="")
		{
			if (!Interpreter::LoadBreakpoints(breakpointsfile))
			{
				Print("Error: Failed to load breakpoints file \""+breakpointsfile+"\".");
			}
		}
	}
    else
    {
        Print("Error: No debugger hostname supplied in command line.");
    }
#endif
	
	//Execute main script
	App* app = new App;
	if (app->Start())
	{
		while (app->Loop()) {}
#ifdef DEBUG
		Interpreter::Disconnect();
#endif
		//Save settings
		delete app;
		if (!System::SaveSettings(settingsfile)) System::Print("Error: Failed to save settings file \"" + settingsfile + "\".");
		return 0;
	}
	else
	{
#ifdef DEBUG
		Interpreter::Disconnect();
#endif
		Steamworks::Shutdown();
		return 1;
	}
}
