// Example showing TProcess usage. Thanks to Graeme G. for sample code

program TProcessExample;

{$mode objfpc} {$h+}

uses sysutils, classes, process;


procedure DoLog(s: string);
begin
  writeln(s);
end;

function RunProcess(const Binary: string; args: TStrings): boolean;
const
  BufSize = 1024;
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
    p.Executable := Binary;

    p.Options := [poUsePipes, poStdErrToOutPut];
//    p.CurrentDirectory := ExtractFilePath(p.Executable);
    p.ShowWindow := swoShowNormal;  // ??? Is this needed?

    p.Parameters.Assign(args);
    DoLog('Running command '+ p.Executable +' with arguments: '+ p.Parameters.Text);
    p.Execute;

    { Now process the output }
    OutputLine:='';
    SetLength(Buf,BufSize);
    repeat
      if (p.Output<>nil) then
      begin
        Count:=p.Output.Read(Buf[1],Length(Buf));
      end
      else
        Count:=0;
      LineStart:=1;
      i:=1;
      while i<=Count do
      begin
        if Buf[i] in [#10,#13] then
        begin
          OutputLine:=OutputLine+Copy(Buf,LineStart,i-LineStart);
          writeln(OutputLine);
          OutputLine:='';
          if (i<Count) and (Buf[i+1] in [#10,#13]) and (Buf[i]<>Buf[i+1]) then
            inc(i);
          LineStart:=i+1;
        end;
        inc(i);
      end;
      OutputLine:=Copy(Buf,LineStart,Count-LineStart+1);
    until Count=0;
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

const
{$ifdef windows}prog = 'cmd';{$endif}

{$ifdef unix}prog = 'ls';{$endif}

var args: TStringList;

{$ifdef windows}
procedure SetArgs;
begin
  args.add('/c');
  args.add('dir');
end;
{$endif}

{$ifdef unix}
procedure SetArgs;
begin
 // does LS require launching shell (sh) ??
end;
{$endif}

begin
  args := TStringList.Create;
  SetArgs;
  RunProcess(prog, args);
  args.free; args := nil;
end.