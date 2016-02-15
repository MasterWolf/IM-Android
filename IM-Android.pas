{
 *
 *  _                       _           _ __  __ _             
 * (_)                     (_)         | |  \/  (_)            
 *  _ _ __ ___   __ _  __ _ _  ___ __ _| | \  / |_ _ __   ___  
 * | | '_ ` _ \ / _` |/ _` | |/ __/ _` | | |\/| | | '_ \ / _ \ 
 * | | | | | | | (_| | (_| | | (_| (_| | | |  | | | | | |  __/ 
 * |_|_| |_| |_|\__,_|\__, |_|\___\__,_|_|_|  |_|_|_| |_|\___| 
 *                     __/ |                                   
 *                    |___/                                                                     
 * 
 * This program is a third party build by ImagicalMine.
 * 
 * ImagicalMine is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * @author PeratX, modified by the ImagicalMine Team
 * @link http://imagicalmine.net
 * 
 *
}

Program IM_Android;

{$mode objfpc}

Uses dos,sysutils;

Const 
	PROG_VER: string = 'v0.9.17 alpha';
	SHELL: string = '/system/bin/sh';

Var 
	HOME: string;
	WORKSPACE: string = '/sdcard/IM/';

Procedure testPerm;
Var 
	t: text;
Begin
	Try
		assign(t,HOME+'settings.conf');
		reset(t);
		close(t);
	Except
		on EInOutError Do
		Begin
			writeln('error> Unable to access '+HOME+'settings.conf : permission denied!');
			halt;
		End;
		Else
			Begin
				writeln('error> Unable to access '+HOME+'settings.conf : unknown error');
				halt;
			End;
	End;
End;

Procedure execBusybox(cmd:String;needLine:boolean = true);
Begin
	exec(HOME+'busybox', cmd);
	If needLine Then writeln;
End;

Procedure execPhp(homedir,fileName:String);

Var t: text;
Begin
	execBusybox('chmod 777 '+HOME+'php');//Set Perm
	assign(t,HOME+'temp.sh');
	rewrite(t);
	writeln(t,'cd '+WORKSPACE);
	writeln(t,'export TMPDIR='+WORKSPACE+'tmp');
	writeln(t,HOME+'php '+fileName);
	close(t);
	exec(SHELL, HOME+'temp.sh');
	erase(t);
End;

Procedure pause;
Begin
	write('system> Press enter to continue.');
	readln;
End;

Procedure throwError(str:String);
Begin
	writeln;
	//textcolor(12);
	writeln('[ERROR] '+str);
	writeln;
	pause;
	//	execBusybox('sleep 1');
End;

Procedure initRuntimeFromZip(fileName:String);
Begin
	execBusybox('unzip -o '+fileName+' -d '+HOME);
End;

Procedure initCoreFromZip(fileName:String);
Begin
	execBusybox('unzip -o '+fileName+' -d '+WORKSPACE);
End;

Procedure writeDefaultWorkspace;
Var t: text;
Begin
	assign(t,HOME+'settings.conf');
	rewrite(t);
	writeln(t,'/sdcard/IM');
	close(t);
End;

Procedure initWorkspace;
Var t: text;
Begin
	If Not fileExists(HOME+'settings.conf') Then
		Begin
			writeDefaultWorkspace;
		End;
	assign(t,HOME+'settings.conf');
	reset(t);
	readln(t,WORKSPACE);
	If Not fileExists(WORKSPACE) Then
		Begin
			throwError('error> Workspace not found, use /sdcard/IM/ as default');
			writeDefaultWorkspace;
			WORKSPACE := '/sdcard/Genisys/';
		End;
	close(t);
End;

Procedure saveWorkspace(dir:String);
Var t: text;
Begin
	If (dir[length(dir)] <> '/') Then dir := dir+'/';
	WORKSPACE := dir;
	assign(t,HOME+'settings.conf');
	rewrite(t);
	writeln(t,dir);
	close(t);
End;

Procedure initPhpConf(force:boolean = false);
Var t: text;
Begin
	If force Or Not fileExists(HOME+'php.ini') Then
		Begin
			assign(t,HOME+'php.ini');
			rewrite(t);
			writeln(t,'date.timezone=CDT');
			writeln(t,'short_open_tag=0');
			writeln(t,'asp_tags=0');
			writeln(t,'phar.readonly=0');
			writeln(t,'phar.require_hash=1');
			close(t);
		End;
End;

Procedure textcolor(int:longint);
Begin;
End;
//usage of CRT unit will cause format errors
{
procedure writeVersion;
var t:text;
begin
	assign(t,HOME+'ver.txt');rewrite(t);
	writeln(t,PROG_VER);
	close(t);
end;

procedure updateExecutable;
begi

procedure checkUpdate;
var
	t:text;
	ver:string;
begin
	if not fileExists(HOME+'ver.txt') then begin
		updateExeutable;
		exit;
	end else begin
		assign(t,HOME+'ver.txt');reset(t);
		readln(ver);
		if ver <> PROG_VRR then begin
			updateExecutable;
			exit;
		end;
	end;
end;
}

Procedure main;
Var opt: string;
Begin
	HOME := extractFilePath(paramStr(0));
	//Auto detect working home
	testPerm;
	initWorkspace;
	initPhpconf;
	//checkUpdate;
	//writeVersion;
	execBusybox('rm '+paramStr(0));
	execBusybox('mkdir '+WORKSPACE, false);
	execBusybox('mkdir '+WORKSPACE+'tmp', false);
	execBusybox('clear');
	textcolor(11);
	//AQUA
	writeln('system> ImagicalMine for Android '+PROG_VER);
	textcolor(13);
	//PURPLE
	writeln('system> Maintained the ImagicalMine Team');
	writeln;
	writeln('system> Home: '+HOME);
	writeln('system> Workspace: '+WORKSPACE);
	writeln;
	textcolor(15);
	//WHITE
	writeln('system> a. Init IM-Android from zip files');
	//	writeln;
	textcolor(6);
	//YELLOW
	writeln('warning> Move php.zip and ImagicalMine.zip into '+WORKSPACE);
	//	writeln;
	textcolor(15);
	writeln('system> b. Launch ImagicalMine');
	//	writeln;
	writeln('system> c. Set workspace');
	//	writeln;
	writeln('system> d. Edit php.ini');
	writeln('warning> Please edit before launch ImagicalMine');
	//	writeln;
	writeln('system> e. Rewrite php.ini');
	writeln;
	writeln('system> i. About IM-Android');
	writeln;
	write('Select: ');

	readln(opt);
	If opt = 'a' Then
		Begin
			initRuntimeFromZip(WORKSPACE+'php.zip');
			initCoreFromZip(WORKSPACE+'ImagicalMine.zip');
			writeln;
			writeln('Done!');
			writeln;
			pause;
			main;
			exit;
		End
	Else If opt = 'b' Then
		Begin
			If Not fileExists(HOME+'php') Then
				Begin
					throwError('error> PHP runtime has not been installed!');
					main;
					exit;
				End;
			writeln;
			writeln('system> Now loading ImagicalMine');
			If fileExists(WORKSPACE+'ImagicalMine.phar') Then execPhp(WORKSPACE, 'ImagicalMine.phar')
			Else If fileExists(WORKSPACE+'src/pocketmine/PocketMine.php') Then execPhp(WORKSPACE, 'src/pocketmine/PocketMine.php')
			Else throwError('system> ImagicalMjne has not been installed!');
			writeln;
			pause;
			main;
			exit;
		End
	Else If opt = 'c' Then
		Begin
			write('system> Please enter the full path of workspace ['+WORKSPACE+'] ');
			readln(WORKSPACE);
			If WORKSPACE = '' Then
				Begin
					writeln;
					writeln('system> Workspace has not changed!');
					writeln;
					pause;
					main;
					exit;
				End
			Else
				If Not fileExists(WORKSPACE) Then
					Begin
						throwError(WORKSPACE+' does not exist');
						writeln;
						pause;
						main;
						exit;
					End
			Else
				Begin
					saveWorkspace(WORKSPACE);
					writeln('system> Workspace has changed to '+WORKSPACE);
					writeln;
					pause;
					main;
					exit;
				End;
		End
	Else If opt = 'd' Then
		Begin
			execBusybox('vi '+HOME+'php.ini');
			pause;
			main;
			exit;
		End
	Else If opt = 'i' Then
		Begin
			execBusybox('clear');
			writeln('system> ImagicalMine for Android');
			writeln('system> Version: '+PROG_VER);
			writeln('system> Please report all bugs to the issue tracker at https://github.com/ImagicalMine/IM-Android/issues.');
			writeln;
			writeln('system> This application is based on Terminal Emulator for Android by jackpal.');
			writeln('system> This program is made by PeratX, modified by the ImagicalMine team.');
			writeln('system> ImagicalMine is a third-party build of PocketMine-MP by the ImagicalMine Team.);
			pause;
			main;
			exit;
		End
	Else If opt = 'e' Then
		Begin
			initPhpConf(true);
			writeln;
			writeln('Done');
			writeln;
			pause;
			main;
			exit;
		End
	Else
		Begin
			throwError('error> Option not found!');
			main;
			exit;
		End;
End;

Begin
	If paramcount = 0 Then main
	Else If paramstr(1) = '-v' Then writeln(PROG_VER);
End.
