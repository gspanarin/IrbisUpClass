unit untMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, irbis64_client, IniFiles;


procedure SaveToFile(str:string);


type
  TForm1 = class(TForm)
    ComboBox1: TComboBox;
    Button1: TButton;
    Memo1: TMemo;
    Label1: TLabel;
    Button2: TButton;
    Edit1: TEdit;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1        : TForm1;
  host         : string;
  port         : string;
  arm          : char;
  user_name    : string;
  password     : string;
  ini          : TIniFile;
  Time         : _SYSTEMTIME;
  yearable     : boolean;
  //ClassList    : TStringList;


implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  combobox1.Items.Text := 'Всех' + #13 + '1 класс' + #13 + '2 класс' + #13 + '3 класс' + #13;
  combobox1.ItemIndex := 0;

  ini := TIniFile.Create( extractfilepath(application.ExeName)+'\upclass.ini');
  try

    host := ini.ReadString('main', 'host', '127.0.0.1');
    port := ini.ReadString('main', 'port', '6666');
    user_name := ini.ReadString('main', 'user_name', '1');
    password := ini.ReadString('main', 'password', '1');
    yearable := ini.ReadBool('main','yearable',false);

  finally
    ini.Free;
  end;

  arm := 'C';

  GetLocalTime(Time);

  if Time.wMonth<6 then
    edit1.Text := inttostr(Time.wYear-1) + '-' + inttostr(Time.wYear)
  else
    edit1.Text := inttostr(Time.wYear) + '-' + inttostr(Time.wYear+1)

  

  //ClassList := TStringList.Create;
  //Classlist.LoadFromFile('classlist.txt');


end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  close;
end;

procedure TForm1.Button1Click(Sender: TObject);

var
  answer: Pchar;    //Буффер для записи
  answerP: Pchar;    //Буффер для поля

  bufsize: integer; //Размер буффера
  retval : integer; //Результат работы функций
  maxMFN : integer; //Максимальное кол-во записей в базе
  MFN : integer;    //Текущая запись, с которой ведется работа
  Adbn: string;     //Имя базы данных - RDR
  Alock: integer;   //параметр, принимающий два значения: 1 - блокировать запись при чтении, 	0 - читать запись без блокировки;
  Aifupdate: integer;//- параметр принимает два значения: 1 - актуализировать запись после записи/обновления; 0 - не актуализировать запись.


  nf :  integer;    //порядковый номер поля (полученный с помощью функции IC_fieldn);
  Amet : integer;   //метка поля;
  Aocc :integer;    //номер повторения поля (начиная с 1).

  delim: char;      //односимвольный разделитель подполя (если задается $00, то выдается значение поля целиком);

  NextClass : string; //Новое значение поля 19
  WordClass : string; //Буква класса
  
  tmp,tmp2  : string;     //Буфер для всяких работ с текстом

  rec : TStringList; //Это буфер для записи, в котором она будет меняться
begin
  Alock := 0;
  Aifupdate := 1;
  bufsize := 100000;
  rec := TStringList.Create;


  //Регистрация
  GetMem(answer, bufsize);
  retval := IC_reg(pchar(host), pchar(port), arm, pchar(user_name), pchar(password), answer, bufsize);
  FreeMem(answer);


  //Регистрация удалась?
  if retval=0 then
  begin


    //Цикл по всем записям РДР
    Adbn := 'RDR';
    maxMFN := IC_maxmfn(Pchar(Adbn));
    if maxMFN>0 then
      for MFN := 1 to maxMFN-1 do
      //for MFN := 1 to 20 do
      begin
        GetMem(answer, bufsize);
        GetMem(answerP, bufsize);

        retval := IC_read(Pchar(Adbn), mfn, Alock, answer, bufsize);
        rec.Text := string(answer);


        //Сделать проверку на лог и физ удаленные записи - у них отрицательный код возврата
        if retval=0 then
        begin

          //Определяем номер поля 19 в записи
          amet := 19;
          aocc := 1;
          nf := IC_fieldn(answer, Amet, Aocc);

          //Проверяем, есть ли поле 19 в этой записи
          if nf>0 then
          begin
            //Читаем поле 19
            delim := 'E';
            retval := IC_field(answer, nf, delim, answerP, bufsize);
            tmp := utf8toansi(string(answerP));
            //Проверяем его содержимое

            if retval = 0 then
            begin

              //Проверяем, что бы этот ученик в этом году еще не был переведен
              if pos(edit1.Text,tmp)=0 then
              begin

                //Проверяем, что бы поле 19 было правильно заполнено
                if pos(copy(tmp,1,1),'123456789')<>0 then
                begin



                  if copy(tmp,2,1)='0' then
                  begin
                    NextClass := '11';
                    WordClass := copy(tmp,3,1)
                  end
                  else
                    if copy(tmp,2,1)='1' then
                    begin
                      NextClass := 'Выпускник';
                      WordClass := '';
                    end
                    else
                    begin
                      NextClass := inttostr(strtoint(copy(tmp,1,1)) + 1);
                      WordClass := copy(tmp,2,1)
                    end;

                  //Меняем поле
                  memo1.Lines.Add('###############################');
                  SaveToFile('###############################');
                  memo1.Lines.Add('Читаем запись с MFN=' + inttostr(mfn));
                  SaveToFile('Читаем запись с MFN=' + inttostr(mfn));
                  memo1.Lines.Add('Старое значение #19: ' + tmp);
                  SaveToFile('Старое значение #19: ' + tmp);
                  memo1.Lines.Add('Новое значение  #19: ' + NextClass + WordClass + ' (' + edit1.Text + ')');
                  SaveToFile('Новое значение  #19: ' + NextClass + WordClass + ' (' + edit1.Text + ')');

                  StrLCopy(answerp,pchar('^E' + ansitoutf8(NextClass + WordClass + ' (' + edit1.Text + ')')),bufsize);

                  retval := IC_fldrep(answer, nf, answerp, bufsize);


                  retval := IC_update(pchar(Adbn), Alock, Aifupdate, answer, bufsize);

                  if retval>0 then
                  begin
                    memo1.Lines.Add('Поле 19 в записи с MFN=' + inttostr(mfn) + ' изменено');
                    SaveToFile('Поле 19 в записи с MFN=' + inttostr(mfn) + ' изменено');
                  end
                  else
                  begin
                    memo1.Lines.Add('При сохранении изменений в записе с MFN=' + inttostr(mfn) + ' возникла ошибка');
                    SaveToFile('При сохранении изменений в записе с MFN=' + inttostr(mfn) + ' возникла ошибка');
                  end;

                end
                else
                  if copy(tmp,1,1)='-' then
                  begin
                    memo1.Lines.Add('В записе с MFN=' + inttostr(mfn) + ' стоит запрет на перевод');
                    SaveToFile('В записе с MFN=' + inttostr(mfn) + ' стоит запрет на перевод');
                  end
                  else
                  begin
                    memo1.Lines.Add('В записе с MFN=' + inttostr(mfn) + ' неправильно заполнено поле 19');
                    SaveToFile('В записе с MFN=' + inttostr(mfn) + ' неправильно заполнено поле 19');
                    memo1.Lines.Add(tmp);
                    SaveToFile(tmp);
                  end;
              end
              else
              begin
                memo1.Lines.Add('В записе с MFN=' + inttostr(mfn) + ' перевод на текущий учебный год уже осуществленн');
                SaveToFile('В записе с MFN=' + inttostr(mfn) + ' перевод на текущий учебный год уже осуществленн');
              end;
            //Сохраняем запись
            end
            else
            begin
              memo1.Lines.Add('При попытке прочитать поле 19 в записе с MFN=' + inttostr(mfn) + ' возникла ошибка (' + inttostr(retval)+ ')');
              SaveToFile('При попытке прочитать поле 19 в записе с MFN=' + inttostr(mfn) + ' возникла ошибка (' + inttostr(retval)+ ')');
            end;

            
          end



        end
        else
          if (retval=-600) or (retval=-601) or (retval=-603) then
            //Это логически и физически удаленные записи
          else
          begin
            memo1.Lines.Add('При попытке прочитать запись с MFN=' + inttostr(mfn) + ' возникла ошибка (' + inttostr(retval)+ ')');
            SaveToFile('При попытке прочитать запись с MFN=' + inttostr(mfn) + ' возникла ошибка (' + inttostr(retval)+ ')');
          end;

        FreeMem(answer);
        FreeMem(answerP);

      end
    else
    begin
      memo1.Lines.Add('При получении максимального количества записей в базе RDR возникла ошибка (' + inttostr(retval)+ ')');
      SaveToFile('При получении максимального количества записей в базе RDR возникла ошибка (' + inttostr(retval)+ ')');
    end;

    //Разрегистрация
    retval := IC_unreg(pchar(user_name));
    if retval <> 0 then
    begin
      //Если разрегистрация не удалась - вывести сообщение об ошибке
      memo1.Lines.Add('При отключении от серера Ирбиса возникла ошибка (' + inttostr(retval)+ ')');
      SaveToFile('При отключении от серера Ирбиса возникла ошибка (' + inttostr(retval)+ ')');
    end;
  end
  else
  begin
    //Если регистрация не удалась - вывести сообщение об ошибке
    memo1.Lines.Add('При подключении к сереру Ирбиса возникла ошибка (' + inttostr(retval)+ ')');
    SaveToFile('При подключении к сереру Ирбиса возникла ошибка (' + inttostr(retval)+ ')');
  end;

end;





procedure SaveToFile(str:string);
var
  f:TextFile;
  FileDir:String;
  t : string;

begin
  GetLocalTime(Time);
  
  t := inttostr(Time.wYear) + inttostr(Time.wMonth) + inttostr(Time.wDay) + ' ' + inttostr(Time.wHour) + ':' + inttostr(Time.wMinute) + ' ';

  FileDir := extractfilepath(application.ExeName) + '\upclass.log';
  AssignFile(f,FileDir);

  if not FileExists(FileDir) then
  begin
    Rewrite(f);
    CloseFile(f);
  end;

  Append(f);
  Writeln(f,t + str);
  Flush(f);
  CloseFile(f);
end;


procedure TForm1.FormShow(Sender: TObject);
begin
  edit1.enabled := yearable;
end;

end.
