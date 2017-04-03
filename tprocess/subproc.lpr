program subproc;
{$mode objfpc}{$H+}
uses sysutils;

var env: string;
begin
  writeln('This is a test executable');
  writeln('a program launched from another');
  writeln;
  env := GetEnvironmentVariable('HTTP_REFERER');
  writeln('Environment variable HTTP_REFERER value: "',env,'"');
  env := GetEnvironmentVariable('OTHERVAR');
  writeln('Environment variable OTHERVAR value: "', env,'"');
  writeln('---end of program---');
end.

