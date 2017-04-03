// Example showing TProcess usage and setting environment

program TProcessExample2;

{$mode objfpc} {$h+}

uses sysutils, classes, process;

procedure DoLog(s: string);
begin
  writeln(s);
end;

function RunProcess(const Binary: string; args: TStrings): boolean;
const
  BufSize = 2048;
var
  p: TProcess;
  Buf: string;
  Count: integer;
  i: integer;
  LineStart: integer;
  OutputLine: string;
begin
  p := TProcess.Create(nil);
  try
    p.Environment.Add('HTTP_REFERER=test');
    p.Environment.Add('OTHERVAR=testdata');
    p.Executable := Binary;

    p.Options := [poUsePipes, poStdErrToOutPut];
    //    p.CurrentDirectory := ExtractFilePath(p.Executable);
    p.ShowWindow := swoShowNormal;  // ??? Is this needed?

    p.Parameters.Assign(args);
    DoLog('Running command '+ p.Executable +' with arguments: '+ p.Parameters.Text);
    p.Execute;

    { Now process the output }
    OutputLine := '';
    SetLength(Buf, BufSize);
    repeat
      if (p.Output <> nil) then
      begin
        Count := p.Output.Read(Buf[1],Length(Buf));
      end
      else
        Count := 0;
      LineStart := 1;
      i := 1;
      while i<=Count do
      begin
        if Buf[i] in [#10,#13] then
        begin
          OutputLine := OutputLine+Copy(Buf,LineStart,i-LineStart);
          writeln(OutputLine);
          OutputLine := '';
          if (i < Count) and (Buf[i+1] in [#10,#13]) and (Buf[i] <> Buf[i+1]) then
            inc(i);
          LineStart := i+1;
        end;
        inc(i);
      end;
      OutputLine := Copy(Buf,LineStart,Count-LineStart+1);
    until Count = 0;
    if OutputLine <> '' then
      writeln(OutputLine);
    p.WaitOnExit;
    Result := p.ExitStatus = 0;
    if not Result then
      Writeln('Command ', p.Executable ,' failed with exit code: ', p.ExitStatus);
  finally
    FreeAndNil(p);
  end;
end;

var args: TStringList;
const
  EXTENSION = {$IFDEF WINDOWS}'.exe'{$ELSE}''{$ENDIF};
  prog = 'subproc' + EXTENSION;

begin
  args := TStringList.Create;
  writeln('---Launching sub program in TProcess---');
  RunProcess(prog, args);
  writeln('---end of launch---');
  args.free; args := nil;
  writeln('Finished main program, <enter> to exit');
  readln;
end.
