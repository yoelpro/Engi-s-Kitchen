unit dataProgram;
{$mode Delphi}
interface
uses
	Sysutils,DateUtils,Math;
type
	mentah = record  //bahanMentah
		nama : string;
		harga: longint;
		exp: integer;
	end;

	olahan = record  //bahanOlahan
		nama : string;
		harga: longint;
		n: integer; //jumlah komponen penyusun
		komponen: array[1..20] of string;
	end;

	resep = record  //resep
		nama : string;
		harga: longint;
		n: integer;
		komponen: array[1..20] of string;
	end;

	invMentah = record //inventory bahan mentah
		nama: string;
		tanggal: TDateTime;
		jumlah: integer;
	end;

	invOlahan = record //inventory bahan mentah
		nama: string;
		tanggal: TDateTime;
		jumlah: integer;
	end;
	
	simulasi = record
		nomor: integer;
		tanggalStart: TDateTime;
		komponen: array[1..11] of longint;
	end;

	rEner = record  	// tipe bentukan agar bisa menampung count dan boolean
		energi : longint;
		CMakan : integer;
		CTidur : integer;
		CIstirahat : integer;
	end;
//--------------------------PROCEDURE-------------------
procedure ubahUang(besar: integer);
procedure ubahEnergy(banyak: integer); // + jika nambah energy, - jika kurang energy
procedure readMentah (var namaFile: string);
procedure readOlahan (var namaFile: string);
procedure readResep (var namaFile: string);
procedure readInvMentah (var namaFile: string);
procedure readInvOlahan (var namaFile: string);
procedure readSimulasi (var namaFile: string );
procedure parser(command: string);
procedure load();
procedure startSimulation(nomorInput:integer);
procedure newSimulation(nomorInput: integer);
procedure resetFileName();
procedure writeSimulasi();
procedure keluar();
procedure belibahan(); {untuk membeli sesuatu}
procedure refreshInv();
procedure upgradeInventori();
procedure olahBahan();
procedure jualOlahan();
procedure jualResep();
procedure refreshCount();
procedure istirahat ();
procedure tidur();
procedure makan ();
procedure cariResep();
procedure writeResep();
procedure tambahResep();
procedure lihatInv();
procedure lihatResep();
procedure lihatStat();
procedure help();
procedure writeInvOlahan();
procedure writeInvMentah();
//------------------FUNCTION----------------------
function copyIdx(kata:string;a,b:integer):string;
function cekExpire(tanggal_input: TDateTime; jumlahInc: integer): boolean;
function cariIdxInv(mode: integer; namaBahan: string): integer;
function cariIdxSimulasi(no: integer): integer;
function cukupUang(besar: integer):boolean;
function cukupInv(besar: integer):boolean;
function validEnergy(banyak: integer):boolean;
function LevenshteinDistance(s, t: string): longint;
var
	nomor, energy: integer;
	jlhSimulasi,jlhMentah,jlhOlahan,jlhResep,jlhInvOlahan,jlhInvMentah: integer;
	jlhItemOlahan,jlhItemMentah: longint;
	fileMentah, fileOlahan, fileResep, fileInvMentah, fileInvOlahan, fileSimulasi: TextFile;
	listMentah: array[1..100] of mentah; //array berisi daftar bahan mentah
	listOlahan: array[1..100] of olahan;
	listResep: array[1..100] of resep;
	listInvMentah: array[1..1001] of invMentah;
	listInvOlahan: array[1..1001] of invOlahan;
	listSimulasi: array[1..100] of simulasi;
	kalimat: string;
	ener : Rener; //energi
	//-------------------
	kapasitasInv: longint; //variable kapasitas inventory
	//nama files
	namaFileMentah : string = 'Bahan Mentah.txt';
	namaFileOlahan : string = 'Bahan Olahan.txt';
	namaFileResep : string = 'Resep.txt';
	namaFileInvMentah : string = '/Inventori Bahan Mentah.txt';
	namaFileInvOlahan: string = '/Inventori Bahan Olahan.txt';
	namaFileSimulasi: string = 'Simulasi.txt';
	//----statistik
	tanggalSekarang: TDateTime; //tanggal dalam simulasi
	noSimulasi : integer;
	tanggalAwal: TDateTime; //tanggal dalam simulasi
	jlhHariHidup: integer;
	mentahBeli, olahanBuat, olahanJual, resepJual : longint; //4 serangkai
	pemasukan, pengeluaran, uang: longint; //berkaitan dengan uang
	//----miscelaneous
	loaded: boolean = false;
	isSimulating : boolean = false;
	doSth: boolean;
	commands: array[1..16] of string;

implementation

function cukupEnergi():boolean;
begin
	if ener.energi > 0 then
	begin
		cukupEnergi:= true;
	end
	else
	begin
		cukupEnergi:= false;
	end;
end;
procedure restock();
var
	total: integer;
	jawab: string;
begin
	if ((jlhHariHidup mod 3=0) and (jlhHariHidup<>0)) then
	begin
		writeln('------------------------Restock------------------------');
		total:= 5000;
		if cukupUang(-1*total) then
		begin
			if cukupInv(-1*10) then
			begin
				writeln('Apakah anda ingin restock 5 air dan 5 telur dengan harga 5000?(y/n)');
				repeat
					readln(jawab);
					if not (jawab='y') or (jawab='n') then
					begin
						writeln('Input invalid!');
					end;
				until (jawab='y') or (jawab='n');
				if jawab='y' then
				begin
					ubahUang(-1*total);
					//UPDATE ARRAY UNTUK AIR
					jlhItemMentah:= jlhItemMentah + 5; //JUMLAH INVENTORY TERPAKAI + x
					jlhInvMentah:= jlhInvMentah + 1; //JUMLAH ARRAY + 1
					listInvMentah[jlhInvMentah].nama:='Air';
					listInvMentah[jlhInvMentah].tanggal:=tanggalSekarang;
					listInvMentah[jlhInvMentah].jumlah:=5;
					//UPDATE ARRAY UNTUK TELUR
					jlhItemMentah:= jlhItemMentah + 5; //JUMLAH INVENTORY TERPAKAI + x
					jlhInvMentah:= jlhInvMentah + 1; //JUMLAH ARRAY + 1
					listInvMentah[jlhInvMentah].nama:='Telur';
					listInvMentah[jlhInvMentah].tanggal:=tanggalSekarang;
					listInvMentah[jlhInvMentah].jumlah:=5;
					//UPDATE STATISTIK
					mentahBeli:= mentahBeli+10;
					pengeluaran:= pengeluaran+total;
					//ENDING
					writeln('Biaya restock anda: ', total);
					writeln('Sisa Uang anda: ',uang);
					writeln('Terima kasih! Barang diantar dan tidak mengurangi energi anda!');
				end
				else
				begin
					writeln('Baik, Terimakasih!');
				end;
			end
			else
			begin
				writeln('Restock gagal! Inventori hanya tersisa ', kapasitasInv-jlhItemMentah-jlhItemOlahan);
			end;
		end
		else
		begin
			writeln('Restock gagal! Uang tidak cukup');
		end;
	end;
	writeInvMentah();
end;
procedure writeInvOlahan();
var
	fileInvOlahan: TextFile;
	i: integer;
begin
	assignfile(fileInvOlahan, namaFileInvOlahan);
	rewrite(fileInvOlahan);
	for i:= 1 to jlhInvOlahan do
	begin
		writeln(fileInvOlahan,listInvOlahan[i].nama,'|',DateToStr(listInvOlahan[i].tanggal),'|',listInvOlahan[i].jumlah);
	end;
	write(fileInvOlahan,'-999');
	CloseFile(fileInvOlahan);
end;

procedure stop();
begin
	writeSimulasi();
	isSimulating:=false;
	resetFileName();
end;

procedure writeInvMentah();
var
	i: integer;
begin
	assignfile(fileInvMentah, namaFileInvMentah);
	rewrite(fileInvMentah);
	for i:= 1 to jlhInvMentah do
	begin
		writeln(fileInvMentah,listInvMentah[i].nama,'|',DateToStr(listInvMentah[i].tanggal),'|',listInvMentah[i].jumlah);
	end;
	write(fileInvMentah,'-999');
	CloseFile(fileInvMentah);
	//writeln('haha')
end;

procedure writeSimulasi();
var
	fileSimulasi: TextFile;
	i,j: integer;
begin
	assignfile(fileSimulasi, 'Simulasi.txt');
	rewrite(fileSimulasi);
	//UPDATE STATISTIK SEBELUM DI TULISKAN
	if isSimulating then
	begin
		listSimulasi[noSimulasi].komponen[1]:=jlhharihidup;
		if ((ener.energi= 10) and doSth) then
		begin
			ener.energi:=-10;
		end;
		listSimulasi[noSimulasi].komponen[2]:=ener.energi;
		listSimulasi[noSimulasi].komponen[3]:=kapasitasInv;
		listSimulasi[noSimulasi].komponen[4]:=mentahBeli;
		listSimulasi[noSimulasi].komponen[5]:=olahanBuat;
		listSimulasi[noSimulasi].komponen[6]:=olahanJual;
		listSimulasi[noSimulasi].komponen[7]:=resepJual;
		listSimulasi[noSimulasi].komponen[8]:=pemasukan;
		listSimulasi[noSimulasi].komponen[9]:=pengeluaran;
		listSimulasi[noSimulasi].komponen[10]:=uang;
	end;
	for i:= 1 to jlhSimulasi do
	begin
		write(fileSimulasi,listSimulasi[i].nomor);
		write(fileSimulasi,'|', DateToStr(listSimulasi[i].tanggalStart));
		for j:=1 to 10 do
		begin
			write(fileSimulasi,'|', listSimulasi[i].komponen[j]);
		end;
		writeln(fileSimulasi);
	end;
	write(fileSimulasi,'-999');
	CloseFile(fileSimulasi);
end;

procedure writeResep();
var
	fileResep: TextFile;
	i,j: integer;
begin
	assignfile(fileResep, 'Resep.txt');
	rewrite(fileResep);
	for i:= 1 to jlhResep do
	begin
		write(fileResep,listResep[i].nama);
		write(fileResep,'|', listResep[i].harga);
		write(fileResep,'|', listResep[i].n);
		for j:=1 to listResep[i].n do
		begin
			write(fileResep,'|', listResep[i].komponen[j]);
		end;
		writeln(fileResep);
	end;
	write(fileResep,'-999');
	CloseFile(fileResep);
end;

procedure newSimulation(nomorInput: integer);
var
	nIdx: Integer; //NEW INDEX
begin
	//PEMBACAAN INVENTORY
	CreateDir(IntToStr(nomorInput));
	namaFileInvMentah:= concat(IntToStr(nomorInput),namaFileInvMentah);
	//writeln('namaFile: ',namaFileInvMentah);
	namaFileInvOlahan:= concat(IntToStr(nomorInput),namaFileInvOlahan);
	assignfile(fileInvMentah,namaFileInvMentah);
	assignfile(fileInvOlahan,namaFileInvOlahan);
	rewrite(fileInvMentah);
	rewrite(fileInvOlahan);
    writeln(fileInvMentah,-999);
    writeln(fileInvOlahan,-999);
    CloseFile(fileInvMentah);
    CloseFile(fileInvOlahan);

    //INISIALISASI KE ARRAY
    nIdx:= jlhSimulasi+1;
    listSimulasi[nIdx].nomor:= nomorInput;
	listSimulasi[nIdx].tanggalStart:= today;
	listSimulasi[nIdx].komponen[1]:=0; //hari hidup
	listSimulasi[nIdx].komponen[2]:=10; // ener.energi
	listSimulasi[nIdx].komponen[3]:=500; // kapasitasInv
	listSimulasi[nIdx].komponen[4]:=0; //mentahBeli:=
	listSimulasi[nIdx].komponen[5]:=0; //olahanBuat:=
	listSimulasi[nIdx].komponen[6]:=0; //olahanJual:=
	listSimulasi[nIdx].komponen[7]:=0; //resepJual:=
	listSimulasi[nIdx].komponen[8]:=5000; //pemasukan:=
	listSimulasi[nIdx].komponen[9]:=0; //pengeluaran:=
	listSimulasi[nIdx].komponen[10]:=5000; //uang:= 

    //LOADING INFO SIMULASI
    noSimulasi:= listSimulasi[nIdx].nomor;
    tanggalAwal:= listSimulasi[nidx].tanggalStart;
	tanggalSekarang:=listSimulasi[nIdx].tanggalStart;
	jlhHariHidup:= listSimulasi[nIdx].komponen[1];
	ener.energi:=listSimulasi[nIdx].komponen[2];
	kapasitasInv:=listSimulasi[nIdx].komponen[3];
	mentahBeli:=listSimulasi[nIdx].komponen[4];
	olahanBuat:=listSimulasi[nIdx].komponen[5];
	olahanJual:=listSimulasi[nIdx].komponen[6];
	resepJual:=listSimulasi[nIdx].komponen[7];
	pemasukan:=listSimulasi[nIdx].komponen[8];
	pengeluaran:=listSimulasi[nIdx].komponen[9];
	uang:= listSimulasi[nIdx].komponen[10];
	jlhSimulasi:= jlhSimulasi+1; //NAMBAH JUMLAH SIMULASI
	writeln('Simulasi baru nomor: ',nomorInput,' akan dijalankan!');
	noSimulasi:= nomorInput;
	isSimulating:=true;
	doSth:=false;
end;

procedure resetFileName();
begin
	namaFileInvMentah:= '/Inventori Bahan Mentah.txt';
	namaFileInvOlahan:= '/Inventori Bahan Olahan.txt';
end;

procedure startSimulation(nomorInput: integer);
var
	idx: Integer;
	error: boolean = false;
begin
	idx:=cariIdxSimulasi(nomorInput);
	//LOADING INFO SIMULASI
	jlhHariHidup:= listSimulasi[idx].komponen[1];
	tanggalAwal:= listSimulasi[idx].tanggalStart;
	tanggalSekarang:=listSimulasi[idx].tanggalStart+jlhHariHidup;
	//writeln('jlhharihidup: ',jlhHariHidup);
	ener.energi:=listSimulasi[idx].komponen[2];
	if ener.energi = 10 then
	begin
		doSth:= false;
	end
	else if (ener.energi = -10) or (ener.energi<10) then
	begin
		ener.energi:= 10;
		doSth:= true;
	end;
	kapasitasInv:=listSimulasi[idx].komponen[3];
	mentahBeli:=listSimulasi[idx].komponen[4];
	olahanBuat:=listSimulasi[idx].komponen[5];
	olahanJual:=listSimulasi[idx].komponen[6];
	resepJual:=listSimulasi[idx].komponen[7];
	pemasukan:=listSimulasi[idx].komponen[8];
	pengeluaran:=listSimulasi[idx].komponen[9];
	uang:= listSimulasi[idx].komponen[10];
	//LOADING INVENTORY SIMULASI
	namaFileInvMentah:= concat(IntToStr(nomorInput),namaFileInvMentah);
	namaFileInvOlahan:= concat(IntToStr(nomorInput),namaFileInvOlahan);
	try
		readInvMentah(namaFileInvMentah);
	except
		On E :Exception do
		begin
		writeln('Error loading file inventori mentah!');
		error:= true;
		end;
	end;

	try
		readInvOlahan(namaFileInvOlahan);;
	except
		On E :Exception do
		begin
		writeln('Error loading file inventori olahan!');
		error:= true;
		end;
	end;
	if not error then
	begin
		writeln('Mulai simulasi ',nomorInput);
		isSimulating:=true;
		noSimulasi:= nomorInput;
		refreshCount();
	end
	else
	begin
		writeln('Terjadi error saat loading file inventori');
		isSimulating:= false;
		resetFileName();
	end;
	
end;

function cukupUang(besar: integer):boolean;
begin
	if uang+besar >= 0 then
	begin
		cukupUang:=true;
	end
	else
	begin
		cukupUang:=false;
	end;
end;

function cukupInv(besar: integer):boolean;
begin
	if kapasitasInv - jlhItemMentah - jlhItemOlahan + (besar) >= 0 then
	begin
		cukupInv:=true;
	end
	else
	begin
		cukupInv:=false;
	end;
end;

procedure ubahUang(besar: integer);// + jika nambah uang, - jika kurang uang
begin
	uang:=uang+ besar;
end;

procedure load();
var
	error: boolean =false;
begin
	try
		readResep(namaFileResep);
	except
		On E :Exception do
		begin
		writeln('Error loading file resep!');
		error:= true;
		end;
	end;
	
	try
		readSimulasi(namaFileSimulasi);
	except
		On E :Exception do
		begin
		writeln('Error loading file simulasi!');
		error:= true;
		end;
	end;

	try
		readOlahan(namaFileOlahan);
	except
		On E :Exception do
		begin
		writeln('Error loading file olahan!');
		error:= true;
		end;
	end;

	try
    	readMentah(namaFileMentah);
 	except
    	On E :Exception do 
    	begin
    	writeln('Error loading file mentah!');
    	error:= true;
    	end;
    end;
	if error= true then
	begin
		writeln('Loading tidak berhasil, ada error!');
	end
	else
	begin
		writeln('Files berhasil loaded, tidak ada error');
		loaded:= true;
	end;
end;

//------------------------------parser
procedure parser(command: string);
var
	j,idx,min: Integer;
	ans : string;
begin
	if loaded then
	begin
		//-----------------start simulation
		if command = 'exit' then
		begin
			stop();
		end
		else if command = 'help' then
		begin
			help();
		end
		else if command = 'start' then
		begin
			if not isSimulating then
			begin
				write('Pilih no simulasi: ');
				readln(nomor);
				if cariIdxSimulasi(nomor)=0 then //START NEW SIMULTION
				begin
					newSimulation(nomor);
				end
				else
				begin
					startSimulation(nomor);
				end;
			end
			else
			begin
				writeln('Simulasi ',noSimulasi,' sedang berjalan!')
			end;
		end
		else if command = 'stop' then
		begin
			if isSimulating = true then
			begin
				stop();
				lihatStat();
			end
			else
			begin
				writeln('Anda memang tidak sedang dalam simulasi!');
			end;
		end
		else if command = 'beliBahan' then
		begin
			if isSimulating = true then
			begin
				if ener.energi-1>=0 then
				begin
					beliBahan();
				end
				else
				begin
					writeln('Tidak cukup energi untuk beli bahan!');
				end;
			end
			else
			begin
				writeln('Anda tidak sedang dalam simulasi!');
			end;
		end
		else if command = 'olahBahan' then
		begin
			if isSimulating = true then
			begin
				if ener.energi-1>=0 then
				begin
					olahbahan();
				end
				else
				begin
					writeln('Tidak cukup energi untuk mengolah bahan!');
				end;
			end
			else
			begin
				writeln('Anda tidak sedang dalam simulasi!');
			end;
		end 
		else if command = 'jualOlahan' then
		begin
			if isSimulating = true then
			begin
				if ener.energi-1>=0 then
				begin
					jualOlahan();
				end
				else
				begin
					writeln('Tidak cukup energi untuk jual olahan!');
				end;
			end
			else
			begin
				writeln('Anda tidak sedang dalam simulasi!');
			end;
		end
		else if command = 'jualResep' then
		begin
			if isSimulating = true then
			begin
				if ener.energi-1>=0 then
				begin
					jualResep();
				end
				else
				begin
					writeln('Tidak cukup energi untuk jual resep!');
				end;
			end
			else
			begin
				writeln('Anda tidak sedang dalam simulasi!');
			end;
		end
		else if command = 'makan' then
		begin
			if isSimulating = true then
			begin
				makan();
			end
			else
			begin
				writeln('Anda tidak sedang dalam simulasi!');
			end;
		end
		else if command = 'istirahat' then
		begin
			if isSimulating = true then
			begin
				istirahat();
			end
			else
			begin
				writeln('Anda tidak sedang dalam simulasi!');
			end;
		end
		else if command = 'tidur' then
		begin
			if isSimulating = true then
			begin
				tidur();
			end
			else
			begin
				writeln('Anda tidak sedang dalam simulasi!');
			end;
		end
		else if command = 'lihatStatistik' then
		begin
			if isSimulating = true then
			begin
				lihatStat();
			end
			else
			begin
				writeln('Anda tidak sedang dalam simulasi!');
			end;
		end
		else if command = 'lihatInventori' then
		begin
			if isSimulating = true then
			begin
				lihatInv();
			end
			else
			begin
				writeln('Anda tidak sedang dalam simulasi!');
			end;
		end
		else if command = 'lihatResep' then
		begin
			lihatResep();
		end
		else if command = 'cariResep' then
		begin
			cariResep();
		end
		else if command = 'tambahResep' then
		begin
			tambahResep();
		end
		else if command = 'upgradeInventori' then
		begin
			upgradeInventori();
		end
		else if command = 'load' then
		begin
			writeln('Load sudah dilakukan');
		end
		else
		begin
			min:= LevenshteinDistance(command,commands[1]);
			idx:= 1;
			for j:=2 to 16 do
			begin
				if LevenshteinDistance(command,commands[j]) < min then
				begin
					min:= LevenshteinDistance(command,commands[j]);
					idx:= j;
				end;
			end;
			writeln('Apakah yang anda maksud ',commands[idx],'? Distance: ',min);
			readln(ans);
			if ans = 'y' then
			begin
				parser(commands[idx]);
			end;
		end;
	end
	else if (command = 'load') and (loaded) then
	begin
		writeln('Load sudah dilakukan');
	end
	else if command = 'exit' then
	begin
		keluar();
	end
	else if (not loaded) and (command <> 'load') then
	begin
		writeln('Silahkan jalankan perintah load terlebih dahulu');
	end
	else //jika dia menjalan perintah load
	begin
		load();
  	end;
end;

function LevenshteinDistance(s, t: string): longint;
  var
    d: array of array of integer;
    i, j, n, m: integer;
  begin
    n := length(t);
    m := length(s);
    setlength(d, m+1, n+1);
 
    for i := 0 to m do
      d[i,0] := i;
    for j := 0 to n do
      d[0,j] := j;
    for j := 1 to n do
      for i := 1 to m do
        if s[i] = t[j] then  
          d[i,j] := d[i-1,j-1]
        else
          d[i,j] := min(d[i-1,j] + 1, min(d[i,j-1] + 1, d[i-1,j-1] + 1));
    LevenshteinDistance := d[m,n];
  end;

procedure help();
begin
	writeln('start');
	writeln('stop');
	writeln('beliBahan');
	writeln('olahBahan');
	writeln('jualOlahan');
	writeln('jualResep');
	writeln('makan');
	writeln('istirahat');
	writeln('tidur');
	writeln('lihatStatistik');
	writeln('lihatInventori');
	writeln('lihatResep');
	writeln('cariResep');
	writeln('tambahResep');
	writeln('upgradeInventori');
	writeln('exit');
end;

procedure keluar();
begin
	writeSimulasi();
end;

//-------------cariIdxSimulasi
function cariIdxSimulasi(no: integer): integer;
var
	i:integer;
begin
	i:=1;
	while (i<=jlhSimulasi) and (listSimulasi[i].nomor<>no) do
	begin
		i:=i+1
	end;
	if listSimulasi[i].nomor=no then
	begin
		cariIdxSimulasi:=i;
	end
	else
	begin
		cariIdxSimulasi:=0;
	end;
end;

//-----------------------------------------------read simulasi
procedure readSimulasi (var namaFile: string);
var
	i:integer=0;
	j:integer;
	posisiD:integer;
begin
	AssignFile(fileSimulasi,namaFile);
	reset(fileSimulasi);
	readln(fileSimulasi,kalimat);
	while (kalimat <> '-999') do
	begin
		i:=i+1;
		//---------------proses send ke array--------------
			//nama
			posisiD:=pos('|',kalimat);
			listSimulasi[i].nomor:= StrToInt(copyIdx(kalimat,1,posisiD-1));
			//harga
			kalimat:= copyIdx(kalimat,posisiD+1,length(kalimat));
			posisiD:=pos('|',kalimat);
			listSimulasi[i].tanggalStart:=StrToDate(copyIdx(kalimat,1,posisiD-1),'DD/MM/YY');
			//read komponen
			kalimat:= concat(copyIdx(kalimat,posisiD,length(kalimat)),'|');//mempersiapkan kalimat
			// 2|Beras|Air -> |Beras|Air|
			for j:= 1 to 10 do
			begin
				posisiD:=pos('|',copyIdx(kalimat,2,length(kalimat)))+1;
				listSimulasi[i].komponen[j]:= StrToInt(copyIdx(kalimat,2,posisiD-1));
				kalimat:= copy(kalimat,posisiD,length(kalimat));
		 	end;
		jlhSimulasi:=i;
		//---------------end send ke array-----------------
		readln(fileSimulasi,kalimat);
	end;
	CloseFile(fileSimulasi);
end;

function validEnergy(banyak: integer):boolean;
begin
	if (energy+banyak > 10) or (energy+banyak < 0) then
	begin
		validEnergy:= false;
	end
	else
	begin
		validEnergy:= true;
	end;
end;

//------------------------------------energy-------------------------------------------------------------------------
procedure ubahEnergy(banyak: integer); // + jika nambah energy, - jika kurang energy
begin
	ener.energi:= ener.energi + banyak;
end;
//------------------------------------end energy----------------------------------------------------------------------

procedure readMentah (var namaFile: string );
var
	i:integer=0;
	posisiD:integer;
begin
	AssignFile(fileMentah,namaFile);
	reset(fileMentah);
	readln(fileMentah,kalimat);
	while (kalimat <> '-999') do
	begin
		i:=i+1;
		//---------------proses send ke array--------------
			//nama
			posisiD:=pos('|',kalimat);
			listMentah[i].nama:= copyIdx(kalimat,1,posisiD-1);
			//harga
			kalimat:= copy(kalimat,posisiD+1,length(kalimat));
			posisiD:=pos('|',kalimat);
			listMentah[i].harga:=StrToInt(copyIdx(kalimat,1,posisiD-1));
			//exp
			kalimat:= copyIdx(kalimat,posisiD+1,length(kalimat));
			posisiD:=pos('|',kalimat);
			listMentah[i].exp:=StrToInt(kalimat);
		//---------------end send ke array-----------------
		readln(fileMentah,kalimat);
	end;
	jlhMentah:=i;
	CloseFile(fileMentah);
end;

procedure readOlahan (var namaFile: string );
var
	i:integer=0;
	j:integer;
	posisiD:integer;
begin
	AssignFile(fileOlahan,namaFile);
	reset(fileOlahan);
	readln(fileOlahan,kalimat);
	while (kalimat <> '-999') do
	begin
		i:=i+1;
		//---------------proses send ke array--------------
			//nama
			posisiD:=pos('|',kalimat);
			listOlahan[i].nama:= copyIdx(kalimat,1,posisiD-1);
			//harga
			kalimat:= copyIdx(kalimat,posisiD+1,length(kalimat));
			posisiD:=pos('|',kalimat);
			listOlahan[i].harga:=StrToInt(copyIdx(kalimat,1,posisiD-1));
			//n
			kalimat:= copyIdx(kalimat,posisiD+1,length(kalimat));
			posisiD:=pos('|',kalimat);
			listOlahan[i].n:=StrToInt(copyIdx(kalimat,1,posisiD-1));
			//read komponen
			kalimat:= concat(copyIdx(kalimat,posisiD,length(kalimat)),'|');//mempersiapkan kalimat
			// 2|Beras|Air -> |Beras|Air|
			j:=1;
			repeat
			begin
				posisiD:=pos('|',copyIdx(kalimat,2,length(kalimat)))+1;
				listOlahan[i].komponen[j]:= copyIdx(kalimat,2,posisiD-1);
				j:=j+1;
				kalimat:= copy(kalimat,posisiD,length(kalimat));
		 	end;
			until j>listOlahan[i].n;
		jlhOlahan:=i;
		//---------------end send ke array-----------------
		readln(fileOlahan,kalimat);
	end;
	CloseFile(fileOlahan);
end;

procedure readResep (var namaFile: string );
var
	i:integer=0;
	j:integer;
	posisiD:integer;
begin
	AssignFile(fileResep,namaFile);
	reset(fileResep);
	readln(fileResep,kalimat);
	while (kalimat <> '-999') do
	begin
		i:=i+1;
		//---------------proses send ke array--------------
			//nama
			posisiD:=pos('|',kalimat);
			listResep[i].nama:= copyIdx(kalimat,1,posisiD-1);
			//harga
			kalimat:= copyIdx(kalimat,posisiD+1,length(kalimat));
			posisiD:=pos('|',kalimat);
			listResep[i].harga:=StrToInt(copyIdx(kalimat,1,posisiD-1));
			//n
			kalimat:= copyIdx(kalimat,posisiD+1,length(kalimat));
			posisiD:=pos('|',kalimat);
			listResep[i].n:=StrToInt(copyIdx(kalimat,1,posisiD-1));
			//read komponen
			kalimat:= concat(copyIdx(kalimat,posisiD,length(kalimat)),'|');//mempersiapkan kalimat
			// 2|Beras|Air -> |Beras|Air|
			j:=1;
			repeat
			begin
				posisiD:=pos('|',copyIdx(kalimat,2,length(kalimat)))+1;
				listResep[i].komponen[j]:= copyIdx(kalimat,2,posisiD-1);
				j:=j+1;
				kalimat:= copy(kalimat,posisiD,length(kalimat));
		 	end;
			until j>listResep[i].n;
		jlhResep:=i;
		//---------------end send ke array-----------------
		readln(fileResep,kalimat);
	end;
	CloseFile(fileResep);
end;

procedure readInvMentah (var namaFile: string );
var
	i:integer=0;
	posisiD:integer;
	total: longint; //berapa kapasitas inv yang terpakai
begin
	total:=0;
	AssignFile(fileInvMentah,namaFile);
	reset(fileInvMentah);
	readln(fileInvMentah,kalimat);
	while (kalimat <> '-999') do
	begin
		i:=i+1;
		//writeln('Pos: ',pos('|',kalimat));
		//---------------proses send ke array--------------
			//nama
			posisiD:=pos('|',kalimat);
			listInvMentah[i].nama:= copyIdx(kalimat,1,posisiD-1);
			//tanggal
			kalimat:= copy(kalimat,posisiD+1,length(kalimat));
			posisiD:=pos('|',kalimat);
			listInvMentah[i].tanggal:=StrToDate(copyIdx(kalimat,1,posisiD-1),'DD/MM/YY');

			//jumlah
			kalimat:= copyIdx(kalimat,posisiD+1,length(kalimat));
			posisiD:=pos('|',kalimat);
			listInvMentah[i].jumlah:=StrToInt(kalimat);
			total:= total+listInvMentah[i].jumlah;
		//---------------end send ke array-----------------
		readln(fileInvMentah,kalimat);
	end;
	jlhInvMentah:=i;
	jlhItemMentah:=total;
	CloseFile(fileInvMentah);
end;

procedure readInvOlahan (var namaFile: string );
var
	i:integer=0;
	posisiD:integer;
	total:longint;
begin
	total:=0;
	AssignFile(fileInvOlahan,namaFile);
	reset(fileInvOlahan);
	readln(fileInvOlahan,kalimat);
	while (kalimat <> '-999') do
	begin
		i:=i+1;
		//---------------proses send ke array--------------
			//nama
			posisiD:=pos('|',kalimat);
			listInvOlahan[i].nama:= copyIdx(kalimat,1,posisiD-1);
			//tanggal
			kalimat:= copy(kalimat,posisiD+1,length(kalimat));
			posisiD:=pos('|',kalimat);
			listInvOlahan[i].tanggal:=StrToDate(copyIdx(kalimat,1,posisiD-1),'DD/MM/YY');
			//jumlah
			kalimat:= copyIdx(kalimat,posisiD+1,length(kalimat));
			posisiD:=pos('|',kalimat);
			listInvOlahan[i].jumlah:=StrToInt(kalimat);
			total:= total + listInvOlahan[i].jumlah;
		//---------------end send ke array-----------------
		readln(fileInvOlahan,kalimat);
	end;
	jlhInvOlahan:=i;
	jlhItemOlahan:=total;
	CloseFile(fileInvOlahan);
end;

function copyIdx(kata:string;a,b:integer):string;
begin
	copyIdx:= copy(kata,a,b-a+1);
end;

function cekExpire(tanggal_input: TDateTime; jumlahInc: integer): boolean; //tanggal input=tanggal exp bahan
var
	tanggalTujuan: TDateTime;
begin
	tanggalTujuan:= IncDay(tanggal_input,jumlahInc);
	if CompareDate(tanggalTujuan,tanggalSekarang) <= 0 then
	begin
		cekExpire:=True;
	end
	else
	begin
		cekExpire:=False;
	end;
end;

function cariIdxInv(mode: integer; namaBahan: string): integer; //CARI INDEX DI ARRAY INVENTORY
var
	i: integer;
begin
	cariIdxInv:=0;//DEFAULT VALUE KALAU TIDAK KETEMU
	//mode 1 mentah
	if mode=1 then
	begin
		for i:= 1 to jlhInvMentah do
		begin
			if namaBahan = listInvMentah[i].nama then
			begin
				cariIdxInv:=i;
			end;
		end;
	end
	else//mode 2 olahan
	begin
		for i:= 1 to jlhInvOlahan do
		begin
			if namaBahan = listInvOlahan[i].nama then
			begin
				cariIdxInv:=i;
			end;
		end;
	end;
end;

function cariIdxList(mode: integer; namaBahan: string): integer; //CARI INDEX DI LIST INVENTORY
var
	i: integer;
begin
	cariIdxList:=0;//DEFAULT VALUE KALAU TIDAK KETEMU
	//mode 1 mentah
	if mode=1 then
	begin
		for i:= 1 to jlhMentah do
		begin
			if namaBahan = listMentah[i].nama then
			begin
				cariIdxList:=i;
			end;
		end;
	end
	else//mode 2 olahan
	begin
		for i:= 1 to jlhOlahan do
		begin
			if namaBahan = listOlahan[i].nama then
			begin
				cariIdxList:=i;
			end;
		end;
	end;
end;

procedure belibahan();{membeli bahan mentah. cttn : sebelum fungsi ini beri pengurangan energi}
var
	jwb : char; {jawabanc apabila mau lanjut beli atau nggak}
	j, x, i : integer; {i itu counter array, x itu jumlah yang mau dibeli}
	harga, total: longint;
	nama : string;
begin
	jwb := 'y';
	writeln('Selamat datang di toko kami.');
	while jwb = 'y' do
	begin
		if not cukupEnergi() then
		begin
			writeln('Energi tidak cukup!');
			break;
		end;
		writeln('Apa yang mau Anda beli?');
		for i:= 1 to jlhMentah do //LISTING MENTAH YANG BISA DIBELI
		begin
			write(i,'. ',listMentah[i].nama,'; ');
			writeln('Harga: ',listMentah[i].harga);
		end;
		write('Pilih nomor: ');
		readln(j);{pilihan bahan}
		while not ((j>0) and (j<=jlhMentah)) do
		begin
			writeln('Pilihan bahan tidak valid');
			readln(j);
		end;
		nama:= listMentah[j].nama;
		harga := listMentah[j].harga;
		writeln('Nama: ',nama,'; Harga: ',harga,'; Uang: ',uang,'; Sisa Inv: ',kapasitasInv-jlhItemMentah-jlhItemOlahan,' -- Mau beli berapa?');
		readln(x); {input jumlah}
		total:= x*harga;
		if cukupUang(-1*total) then
		begin
			if cukupInv(-1*x) then
			begin
				ubahUang(-1*total);
				//UPDATE ARRAY
				jlhItemMentah:= jlhItemMentah + x; //JUMLAH INVENTORY TERPAKAI + x
				jlhInvMentah:= jlhInvMentah+1; //JUMLAH ARRAY + 1
				listInvMentah[jlhInvMentah].nama:=nama;
				listInvMentah[jlhInvMentah].tanggal:=tanggalSekarang;
				listInvMentah[jlhInvMentah].jumlah:=x;
				//UPDATE STATISTIK
				mentahBeli:= mentahBeli+x;
				pengeluaran:= pengeluaran+total;
				//UBAH ENERGY
				ener.energi:= ener.energi - 1;
				//ENDING
				writeln('Total belanjaan anda: ', total);
				writeln('Sisa Uang anda: ',uang);
			end
			else
			begin
				writeln('Inventory tidak cukup!');
			end;
		end
		else
		begin
			writeln('Uang Tidak Cukup!');
		end;
		writeln('Ada lagi yang ingin Anda beli? (y/n)');
		readln(jwb);
	end;
	writeln('Terimakasih dan selamat tinggal :D');
	writeInvMentah();
	doSth:= true;
end;

procedure olahbahan();{ngloha bahan lalu masukkin}
var
	j, k, i: integer; {j : yang mau di olah, k : counter bahan}
	lengkap : boolean=true;
	nama: string;
begin
	Writeln('Pengolahan Bahan Olahan');
	Writeln('Apa yang ingin Anda buat?');

	for i:= 1 to jlhOlahan do//LISTING
	begin
		write(i,'. ',listOlahan[i].nama,'; ');
		writeln('Harga: ',listOlahan[i].harga);
	end;
	readln(j);{pilihan bahan}
	while not ((j>0) and (j<=jlhOlahan)) do
	begin
		writeln('Pilihan bahan tidak valid');
		readln(j);
	end;
	nama:= listOlahan[j].nama;
	k := 1;

	for k:=1 to listOlahan[j].n do//PERIKSA KELENGKAPAN BAHAN
	begin
		if cariIdxInv(1,listOlahan[j].komponen[k]) = 0 then
		begin
			lengkap:=false;
			break;
		end;
	end;

	if lengkap = true then {bahan ada dan lanjut untuk diproses}
	begin
		//PENGURANGAN JUMLAH BAHAN MENTAH
		begin
		for k:=1 to listOlahan[j].n do
			listInvMentah[cariIdxInv(1,listOlahan[j].komponen[k])].jumlah:= listInvMentah[cariIdxInv(1,listOlahan[j].komponen[k])].jumlah - 1;
			jlhItemMentah:= jlhItemMentah - listOlahan[j].n;
		end;
		jlhInvOlahan:= jlhInvOlahan+1;
		//PENAMBAHAN KE ARRAY
		listInvOlahan[jlhInvOlahan].nama:= nama;
		listInvOlahan[jlhInvOlahan].tanggal:= tanggalSekarang;
		listInvOlahan[jlhInvOlahan].jumlah:= listInvOlahan[jlhInvOlahan].jumlah +1 ;
		//UPDATE STATISTIK
		jlhItemOlahan:= jlhInvOlahan+1;
		olahanBuat:=olahanBuat+1;
		//PENGURANGAN ENERGI
		ubahEnergy(-1);
		Writeln(nama,' berhasil dibuat!');
	end
	else
	begin
		writeln('Bahan tidak lengkap!');
	end;
	refreshInv();
	writeInvOlahan();
	writeInvMentah();
	doSth:= true;
end;

procedure refreshInv();
//mengupdate isi inventory ketika hari lewat
var
   k,j: integer;
    
begin
    //mentah
    k:=1;
    while k <= jlhInvMentah do
    begin
        if (cekExpire(listInvMentah[k].tanggal, listMentah[cariIdxList(1,listInvMentah[k].nama)].exp)) or (listInvMentah[k].jumlah=0) then
        begin
            jlhItemMentah:=jlhItemMentah-listInvMentah[k].jumlah;
            for j:= k to jlhInvMentah do //shift up
            begin
                listInvMentah[j].nama:=listInvMentah[j+1].nama;
                listInvMentah[j].tanggal:=listInvMentah[j+1].tanggal;
                listInvMentah[j].jumlah:=listInvMentah[j+1].jumlah;
            end;
            jlhInvMentah:=jlhInvMentah-1;
            k:=k-1;
        end;
        k:=k+1;
    end;
    //Olahan
    k:=1;
    while k <= jlhInvOlahan do
    begin
        if (cekExpire(listInvOlahan[k].tanggal, 3)) or (listInvOlahan[k].jumlah=0) then
        begin
            jlhItemOlahan:=jlhItemOlahan-listInvOlahan[k].jumlah;
            for j:= k+1 to jlhInvOlahan do //shift up
            begin
                listInvOlahan[j-1].nama:=listInvOlahan[j].nama;
                listInvOlahan[j-1].tanggal:=listInvOlahan[j].tanggal;
                listInvOlahan[j-1].jumlah:=listInvOlahan[j].jumlah;
            end;
            jlhInvOlahan:=jlhInvOlahan-1;
            k:=k-1;
        end;
        k:=k+1;
    end;
    writeInvMentah();
	writeInvOlahan();
end;

procedure upgradeInventori();
//menambah maksimum inventory
var
	jawab: string;
	angka: integer;
begin
	if isSimulating=true then
	begin
		if cukupUang(-10000) then
		begin
			writeln('Ingin menambah kapasitas inventori sebesar 500 dengan harga 10000?(y/n)');
			readln(jawab);
			if jawab='y' then
			begin
				kapasitasInv := kapasitasInv + 500;
	    		writeln('Kapasitas inv telah bertambah ',500);
		    	ubahUang(-10000);
				pengeluaran:= pengeluaran + 10000; //pengeluaran
				writeSimulasi();
		    end;
		end
		else
		begin
			writeln('Tidak cukup uang!');
		end;
	end
	else
	begin
		writeln('Mau upgrade inventory pada simulasi berapa?');
		readln(angka);
		if listSimulasi[angka].komponen[10] - 10000 >= 0 then
		begin
			listSimulasi[angka].komponen[3]:= listSimulasi[angka].komponen[3] + 500; //kapasitas inventori
			listSimulasi[angka].komponen[9]:= listSimulasi[angka].komponen[9]+ 10000; //pengeluaran
			listSimulasi[angka].komponen[10]:= listSimulasi[angka].komponen[10] -10000; //ubah uang
			writeSimulasi();
			writeln('Inventori pada simulasi ',angka,' berhasil ditambah 500!');
		end
		else
		begin
			writeln('Uang tidak cukup!');
		end;
	end;
	writeln('Terima kasih dan sampai jumpa!');
end;

procedure jualOlahan(); {fileInvOlahan = namaFile} {jual olahan}
var
	jwb : char; {jawabanc apabila mau lanjut jual atau nggak}
	jumlah,pertinggal, j, i, x : integer; {j itu counter array, x itu jumlah yang mau dijual}
	harga : longint;
	nama : string;
begin
	jwb := 'y';
	while jwb = 'y' do
	begin
		if not cukupEnergi() then
		begin
			writeln('Energi tidak cukup!');
			break;
		end;
		writeln('Selamat datang!');
		writeln('Apa yang mau Anda jual?');
		for i:= 1 to jlhOlahan do
		begin
			write(i,'. ',listOlahan[i].nama,'; ');
			writeln('Harga: ',listOlahan[i].harga);
		end;
		readln(j);{pilihan bahan}
		while not ((j>0) and (j<=jlhOlahan)) do
		begin
			writeln('Pilihan bahan tidak valid');
			readln(j);
		end;
		nama := listOlahan[j].nama;
		harga := listOlahan[j].harga;
		jumlah:=0;
		for i:= 1 to jlhInvOlahan do
		begin
			if listInvOlahan[i].nama=nama then
			begin
				jumlah:= jumlah + listInvOlahan[i].jumlah;
			end;
		end;
		if jumlah = 0 then
		begin
			writeln('Bahan olahan yang dipilih tidak tersedia');
		end
		else
		begin
			writeln('Nama: ',nama,' Harga satuan: ',harga,' Tersedia: ',jumlah); {display olahan}
			writeln('Jual berapa?');
			readln(x); {input jumlah}
			pertinggal:=x;
			if (x <= jumlah) then //LANJUT KE PENJUALAN
			begin
				//PENGURANGAN JUMLAH SATU PER SATU
				for i:= 1 to jlhInvOlahan do
				begin
					if listInvOlahan[i].nama=nama then
					begin
						if listInvOlahan[i].jumlah <= x then
						begin
							x:= x - listInvOlahan[i].jumlah;
							listInvOlahan[i].jumlah:=0;
						end
						else
						begin
							listInvOlahan[i].jumlah:= listInvOlahan[i].jumlah - x;
						end;
					end;
				end;
				//UPDATE STATISTIK
				jlhItemOlahan:= jlhInvOlahan-pertinggal;
				olahanJual:=olahanjual+pertinggal;
				pemasukan:= pemasukan + pertinggal*harga;
				uang:= uang + pertinggal*harga;
				//PENGURANGAN ENERGI
				ubahEnergy(-1);
				writeln('Energi tersisa: ',ener.energi);
				//Writeln(nama,' berhasil dibuat!');
			end
			else
			begin
				writeln('Permintaan anda tidak dapat dipenuhi!');
			end;
		end;
		refreshInv();
		writeInvOlahan();
		writeln('Ada lagi yang ingin Anda jual? (y/n)');
		readln(jwb);
		end;
	writeln('Terimakasih dan selamat tinggal :D');
	doSth:= true;
end;

procedure jualResep(); {file 1 = inv mentah, file2 inv olah} {milih resep, olah, jual}
var
	idx, j, i: integer;
	found : boolean=true;
	harga: longint;
begin
	Writeln('Penjualan resep');
	Writeln('Apa yang ingin Anda masak?');
	for i:= 1 to jlhResep do
	begin
		write(i,'. ',listResep[i].nama,'; ');
		writeln('Harga: ',listResep[i].harga);
	end;
	harga:= listResep[i].harga;
	readln(j);{pilihan bahan}
	while not ((j>0) and (j<=jlhResep)) do
	begin
		writeln('Pilihan resep tidak valid');
		readln(j);
	end;
	//PERIKSA APAKAH BAHAN MENTAH DAN OLAHAN CUKUP
	for i:= 1 to listResep[j].n do
	begin
		if (cariIdxInv(1,listResep[j].komponen[i]) = 0) and (cariIdxInv(2,listResep[j].komponen[i])=0) then
		begin
			found:= false;
			break;
		end;
	end;

	if found = true then
	begin
		//PENGURANGAN BAHAN
		for i:= 1 to listResep[j].n do
		begin
			if cariIdxInv(1,listResep[j].komponen[i]) <> 0 then //MERUPAKAN BAHAN MENTAH
			begin
				idx:= cariIdxInv(1,listResep[j].komponen[i]);
				listInvMentah[idx].jumlah:= listInvMentah[idx].jumlah-1;
				jlhItemMentah:= jlhItemMentah-1; //DELETE JLH ITEM MENTAH
			end
			else
			begin
				idx:= cariIdxInv(2,listResep[j].komponen[i]);
				listInvOlahan[idx].jumlah:= listInvOlahan[idx].jumlah-1;
				jlhItemOlahan:= jlhItemOlahan-1; //DELETE JLH ITEM OLAHAN
			end;
		end;
		//UPDATE STATISTIK
		resepJual:=resepJual+1;
		pemasukan:= pemasukan + harga;
		uang:= uang + harga;
		//PENGURANGAN ENERGI
		ubahEnergy(-1);
		writeln('Energi tersisa: ',ener.energi);
		refreshInv();
	end
	else
	begin
		writeln('Bahan mentah atau bahan olahan tidak tersedia!');
	end;
	doSth:= true;
end;

procedure makan ();
begin
		if (ener.Cmakan<3) then
		begin
			ener.Cmakan := ener.Cmakan+1;
			if (ener.energi+3>10) then
			begin
				ener.energi := 10; //energi maksimum 10 
			end
			else
			begin
				ener.energi := ener.energi +3;
			end;
			writeln('Makan berhasil dilakukan, energi = ',ener.energi);
			doSth:=true;
		end
		else
		begin
			writeln('Anda sudah makan 3x, tidak dapat makan lagi!');
		end;
end;

procedure Istirahat ();
begin
	if (ener.Cistirahat<6) then
	begin
		if (ener.energi+1>10) then
		begin
			ener.energi := 10;
		end
		else
		begin
			ener.energi := ener.energi +1;
		end;
		writeln('Istirahat berhasil! Energi: ',ener.energi);
		ener.Cistirahat:= ener.Cistirahat + 1;
		doSth:=true;
	end
	else
	begin
		writeln('Anda sudah 6x istirahat!');
	end;
end;

procedure tidur();
begin
	if doSth then
	begin
		ener.energi :=10;
		refreshCount();
		jlhHariHidup:=jlhHariHidup+1;
		Writeln('Sebelum: ',DateToStr(tanggalSekarang));
		tanggalSekarang:= IncDay(tanggalSekarang);{memanggil prosedur ganti hari}
		Writeln('Sekarang: ',DateToStr(tanggalSekarang));
		refreshInv();
		doSth:=false;
		if jlhHariHidup = 10 then
		begin
			writeln('------------------------TAMAT------------------------');
			lihatStat();
			writeln('Simulasi anda sudah mencapai hari ke-10, anda akan keluar dari simulasi');
			writeln('Tekan enter untuk melanjutkan..');
			readln();
			stop();
		end
		else
		begin
			restock();
		end;
	end
	else
	begin
		writeln('Lakukan sesuatu sebelum tidur!');
	end;
end;

procedure refreshCount();
begin
	ener.CMakan := 0;
	ener.Cistirahat := 0;
	ener.CTidur :=0;
end;

procedure cariResep();
var
	ulang, nama: string;
	i,idx:integer;
	found:boolean=false;
begin
	repeat
		writeln('Resep apa yang anda cari?');
		readln(nama);
		for i:= 1 to jlhResep do
		begin
			if listResep[i].nama = nama then
			begin
				idx:=i;
				found:= true;
			end;
		end;
		if found= true then
		begin
			Writeln('Nama resep: ',listResep[idx].nama);
			Writeln('Harga: ',listResep[idx].harga);
			for i:= 1 to listResep[idx].n do
			begin
				writeln('Komponen ',i,': ',listResep[idx].komponen[i]);
			end;
		end
		else
		begin
			writeln('Resep tidak ditemukan!');
		end;
		writeln('Apakah anda ingin mencari resep lagi? (y/n)');
		readln(ulang);
		writeln('-------------------------------------------')
		until ulang = 'n';
end;

procedure tambahResep();
var
	ulang, nama, kata: string;
	n,i: integer;
	data: array[1..20] of string;
	harga, total: longint;
	found: boolean= false;
	input: double;
begin
	repeat
		harga:= 0;
		total:= 0;
		writeln('--------------Proses penambahan resep--------------');
		write('Masukkan nama resep yang ingin ditambahkan: ');
		readln(nama);
		for i:= 1 to jlhResep do
		begin
			if nama=listResep[i].nama then
			begin
				found:= true;
				break;
			end;
		end;
		if found = false then
		begin
			write('Jumlah komponen resep: ');
			repeat
				readln(n);
				if ((n <= 1) or (n>20)) then
				begin
					writeln('Jumlah Resep Invalid!');
				end;
			until ((n > 1) and (n<=20));
			for i:= 1 to n do
			begin
				write('Masukkan nama komponen ',i,': ');
				readln(kata);
				while (cariIdxList(1,kata)=0) and (cariIdxList(2,kata)=0) do
				begin
					writeln('Komponen yang anda masukkan tidak terdefinisi!');
					write('Masukkan nama komponen ',i,': ');
					readln(kata);
				end;
				if cariIdxList(1,kata)<>0 then
				begin
					data[i]:= kata;
					total:= total + ceil(listMentah[cariIdxList(1,kata)].harga*1.25);
				end
				else
				begin
					data[i]:= kata;
					total:= total + ceil(listMentah[cariIdxList(2,kata)].harga*1.25);
				end;
			end;
			write('Masukkan harga: ');
			readln(input);
			while floor(input) < total do
			begin
				writeln('Harga resep minimal: ',total);
				write('Masukkan harga: ');
				readln(input);
			end;
			harga:= floor(input);
			Writeln('Resep berhasil didaftarkan!');
			//WRITE KE ARRAY ASLI
			jlhResep:=jlhResep+1;
			listResep[jlhResep].nama := nama;
			listResep[jlhResep].harga:= harga;
			listResep[jlhResep].n:= n;
			for i:= 1 to n do
			begin
				listResep[jlhResep].komponen[i]:= data[i];
			end;
			writeResep();
		end
		else
		begin
			Writeln('Resep sudah pernah didaftarkan!');
		end;
		Writeln('Apakah anda ingin menambahkan resep lagi?(y/n)');
		readln(ulang);
	until ulang = 'n';
end;

procedure lihatInv();
var
	i,j: integer;
	temp1 : invMentah;
	datat1 : array[1..1001] of invMentah;
	temp2 : invOlahan;
	datat2 : array[1..1001] of invOlahan;
begin
	//MENTAH
    for i:=1  to jlhInvMentah do
    begin
      datat1[i]:= listInvMentah[i];
    end;

    for i:=jlhInvMentah downto 2 do
    begin
        for j:=1 to i-1 do
        if datat1[j].nama > datat1[j+1].nama then
        begin
           temp1          := datat1[j+1];
           datat1[j+1]:=datat1[j];
           datat1[j]  :=temp1;
        end;
    end;
    //OUTPUT
    writeln('List Inventori Mentah');
    if jlhInvMentah = 0 then
    begin
    	writeln('Kosong');
    end
    else
    begin
    	for i:=1  to jlhInvMentah do
	    begin
	     	writeln('Nama: ',datat1[i].nama);
	      	writeln('Tanggal Beli: ',DateToStr(datat1[i].tanggal));
	      	writeln('Jumlah: ',datat1[i].jumlah);
	      	writeln('-------------------------')
	    end;
    end;
    
    writeln();
    //OLAHAN
    for i:=1  to jlhInvOlahan do
    begin
      datat2[i]:= listInvOlahan[i];
    end;
    
    for i:=jlhInvOlahan downto 2 do
    begin
        for j:=1 to i-1 do
        if datat2[j].nama > datat2[j+1].nama then
        begin
           temp2         := datat2[j+1];
           datat2[j+1]:=datat2[j];
           datat2[j]  :=temp2;
        end;
    end; 
    //OUTPUT
    writeln('List Inventori Olahan');
    if jlhInvOlahan = 0 then
    begin
    	writeln('Kosong');
    end
    else
    begin
    	for i:=1  to jlhInvOlahan do
	    begin
	      	writeln('Nama: ',datat2[i].nama);
	      	writeln('Tanggal Beli: ',DateToStr(datat2[i].tanggal));
	      	writeln('Jumlah: ',datat2[i].jumlah);
	      	writeln('-------------------------')
	    end;
    end;
end;

procedure lihatResep();
var
	i,j: integer;
	temp : resep;
	datat : array[1..100] of resep;
begin
	//Menyalin resep ke data temporary
    for i:=1  to jlhResep do
    begin
      datat[i]:= listResep[i];
    end;

    for i:=jlhResep downto 2 do
    begin
        for j:=1 to i-1 do
        if datat[j].nama > datat[j+1].nama then
        begin
           temp          := datat[j+1];
           datat[j+1]:=datat[j];
           datat[j]  :=temp;
        end;
    end;
    //OUTPUT
    writeln();
    writeln('List Resep');
    for i:=1  to jlhResep do
    begin
     	writeln('Nama: ',datat[i].nama);
      	writeln('Harga: ',datat[i].harga);
      	write('Komponen: ', datat[i].komponen[1]);
      	for j:= 2 to datat[i].n do
      	begin
      		write(', ',datat[i].komponen[j]);
      	end;
      	writeln();
      	writeln('-------------------------')
    end;
end;

procedure lihatStat();
begin
		writeln('No simulasi: ',noSimulasi);
		writeln('Jumlah list mentah terdefinisi: ',jlhMentah);
		writeln('Jumlah list olahan terdefinisi: ',jlhOlahan);
		writeln('Jumlah list resep terdefinisi: ',jlhResep);
		writeln('Jumlah energi: ',ener.energi);
		writeln('Jumlah item mentah: ',jlhItemMentah);
		writeln('Jumlah item olahan: ',jlhItemOlahan);
		writeln('Kapasitas inventori maksimum: ',kapasitasInv);
		writeln('Tanggal awal: ',DateToStr(tanggalAwal));
		writeln('Tanggal sekarang: ',DateToStr(tanggalSekarang));
		writeln('Jumlah hari hidup: ',jlhHariHidup);
		writeln('Mentah dibeli: ',mentahBeli);
		writeln('Olahan dibuat: ',olahanBuat);
		writeln('Olahan dijual: ',olahanJual);
		writeln('Resep dijual: ',resepJual);
		writeln('Pemasukan: ',pemasukan);
		writeln('Pengeluaran: ',pengeluaran);
		writeln('Uang: ',uang);
end;

end.
