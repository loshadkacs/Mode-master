#define DOWNLOAD_FILE		"addons/sourcemod/configs/mods_master/download.txt"

stock LoadDownloadFiles()
{
	new Handle:hFile = OpenFile(DOWNLOAD_FILE, "r");
	if(hFile != INVALID_HANDLE)
	{
		decl String:buffer[256];

		while(ReadFileLine(hFile, buffer, 256)) 
		{
			TrimString(buffer);
			if(buffer[0] && strncmp(buffer, "//", 2, true) != 0) AddFileToDownloadsTable(buffer);  
		} 
		
		CloseHandle(hFile); 
	}
}