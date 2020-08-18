@echo off
::Mikael Leuf
::2020-02-28

CHCP 65001>NULL
setlocal enableDelayedExpansion
set header=ID   Name          Weight  L    B    H 

:COMMAND_PARAM
	IF "%1"=="/?" (
		GOTO :HELP_TEXT
		GOTO :EOF
	)
	IF exist "%1" IF "%2"=="" ( 
		set file=%1
		GOTO :INTERACTIVE 
	)

	IF NOT EXIST "%1" (
		CALL :NO_FILE
		GOTO :EOF
	) ELSE (
		SET file=%1
	)
	IF /I "%2"=="/backup" (
		GOTO :MAKE_BACKUP
	)
	IF /I "%2"=="/print" (
		GOTO :PRINT_FILE
	)
	IF "%3"=="" ( GOTO :HELP_TEXT )
	IF /I "%2"=="/sort" (
		SET "sort_option=%3"
		GOTO :SORT_FILE
	)

	GOTO :EOF
:END_COMMAND_PARAM

:INTERACTIVE
	CALL :INTER_HELP
	
	CHOICE /C bpshq

	IF %ERRORLEVEL%==1 ( 
		IF NOT EXIST !file! ( CALL :NO_FILE ) ELSE ( CALL :MAKE_BACKUP )
	)
	IF %ERRORLEVEL%==2 ( 
		IF NOT EXIST !file! ( CALL :NO_FILE ) ELSE ( CALL :PRINT_FILE )
	)
	IF %ERRORLEVEL%==3 ( 
		IF NOT EXIST !file! ( CALL :NO_FILE ) ELSE ( CALL :SORT_FILE )
	)
	IF %ERRORLEVEL%==4 ( CALL :INTER_HELP )

	IF %ERRORLEVEL%==5 ( GOTO :EOF )

	GOTO INTERACTIVE
	
:END_INTERACTIVE

:MAKE_BACKUP
	COPY %file% %file%.backup
	ECHO "Backup generated"
	ECHO:
	EXIT /B
:END_BACKUP

:PRINT_FILE
	ECHO %header%
	TYPE %file%
	ECHO:
	EXIT /B
:END_PRINT

:SORT_FILE
	IF /I "%sort_option%"=="" ( 
		SET /P "sort_option=Chose a column to sort by:" 
	)

	SET new_file=%file%.temp

	for /F "tokens=1-6 delims=," %%A in (%file%) do (
		SET "coli=%%A"
		SET "coln=%%B"
		SET "colv=%%C"
		SET "coll=%%D"
		SET "colb=%%E"
		SET "colh=%%F"
		
		ECHO !col%sort_option%! ,!coli!,!coln!,!colv!,!coll!,!colb!,!colh! >> %new_file%		
	)
	ECHO %header%
	for /F "usebackq tokens=1,* delims=," %%A in (`sort %new_file%`) do ( ECHO %%B )
	ECHO:
	SET sort_option=
	DEL %new_file%
	EXIT /B
:END_SORT

:NO_FILE
	IF NOT EXIST !file! ( ECHO "No file was set." )
	ECHO:
	EXIT /B
:END_NO_FILE

:INTER_HELP
	ECHO "Commands"
	ECHO "b make backup"
	ECHO "p print file"
	ECHO "s sort file by column { i | n | v | l | b | h }"
	ECHO "h help"
	ECHO "q quit"
	ECHO:
	EXIT /B
:END_INTER_HELP

:HELP_TEXT
	ECHO "används för logistikhantering."
	ECHO "Syntax : logistics [ enhet :] sökväg [/ backup | / print | / sort <i | n | v | l | b | h >]"
	ECHO "/backup 	Genererar en säkerhetskopia av datafilen i samma katalog."
	ECHO "/print 		Skriver ut innehållet i datafilen."
	ECHO "/sort 		Sorterar och skriver ut innehållet i datafilen."
	ECHO "			i efter produktnummer	n efter namn"
	ECHO "			v efter vikt 			l efter längd"
	ECHO "			b efter bredd 			h efter höjd"
	ECHO "/? 			Skriver ut den här hjälptexten."
	ECHO:
	EXIT /B
:END_HELP_TEXT
