Program Main;
{$mode Delphi}
Uses
	dataProgram,DateUtils,Sysutils,Math;
var
	input: string;


begin
	commands[1]:='start';
	commands[2]:='stop';
	commands[3]:='beliBahan';
	commands[4]:='olahBahan';
	commands[5]:='jualOlahan';
	commands[6]:='jualResep';
	commands[7]:='makan';
	commands[8]:='istirahat';
	commands[9]:='tidur';
	commands[10]:='lihatStatistik';
	commands[11]:='lihatInventori';
	commands[12]:='lihatResep';
	commands[13]:='cariResep';
	commands[14]:='tambahResep';
	commands[15]:='upgradeInventori';
	commands[16]:='exit';
	writeln('Selamat datang di engi kitchen');
	repeat
		if isSimulating then
		begin
			write('>>');
		end
		else
		begin
			write('>');
		end;
		readln(input);
		parser(input);
	until input = 'exit';
end.
