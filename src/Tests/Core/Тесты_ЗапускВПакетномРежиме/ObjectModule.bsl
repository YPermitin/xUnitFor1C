﻿Перем КонтекстЯдра;
Перем Ожидаем;

Перем ПарсерКоманднойСтроки;
Перем ИмяКаталогаВременныхФайлов;
Перем ФайлЛогаUI;
Перем ФайлСОтчетомОТестировании;

// Переменная с путем к обработке в файловой системы
// Используется в случаях, когда обработка запущена из встроенного в конфигурацию браузера тестов,
// т.к. в этом случае в свойстве ИспользуемоеИмяФайла содержится адрес временного хранилища, а не непосредственный путь
Перем ПутьКФайлуПолный Экспорт;

Процедура Инициализация(КонтекстЯдраПараметр) Экспорт
	КонтекстЯдра = КонтекстЯдраПараметр;
	Ожидаем = КонтекстЯдра.Плагин("УтвержденияBDD");
	ПарсерКоманднойСтроки = КонтекстЯдра.Плагин("ПарсерКоманднойСтроки");
КонецПроцедуры

Функция ПолучитьСписокТестов() Экспорт
	ВсеТесты = Новый Массив;
	
	// Для встроенной в состав конфигурации подсистемы xUnitFor1C тесты еще не адаптированы
	Попытка // На случай, если контекст не определен на момент получения тестов
		Если КонтекстЯдра.ЭтоВстроеннаяОбработка Тогда
			Возврат ВсеТесты;
		КонецЕсли;
	Исключение
	КонецПопытки;
	
	// Позитивные
	ВсеТесты.Добавить("ТестДолжен_ПроверитьЗапускВПакетномРежиме_ТолстыйКлиент");
	ВсеТесты.Добавить("ТестДолжен_ПроверитьЗапускВПакетномРежиме_ТонкийКлиент");
	// Негативные
	ВсеТесты.Добавить("ТестДолжен_ПроверитьЗапускВПакетномРежиме_ТолстыйКлиент_СПлохимиПараметрами_xddRun");
	ВсеТесты.Добавить("ТестДолжен_ПроверитьЗапускВПакетномРежиме_ТолстыйКлиент_СПлохимиПараметрами_xddReport");
	ВсеТесты.Добавить("ТестДолжен_ПроверитьЗапускВПакетномРежиме_ТонкийКлиент_СПлохимиПараметрами_xddRun");
	ВсеТесты.Добавить("ТестДолжен_ПроверитьЗапускВПакетномРежиме_ТонкийКлиент_СПлохимиПараметрами_xddReport");
	
	Возврат ВсеТесты;
КонецФункции

Процедура ПередЗапускомТеста() Экспорт
	Если КонтекстЯдра.ЭтоВстроеннаяОбработка Тогда
		ВызватьИсключение "[Pending] Тестирование пакетного запуска не реализовано для встроенной в конфигурацию подсистемы";
	КонецЕсли;
	
	ИмяКаталогаВременныхФайлов = ПолучитьИмяВременногоФайла();
	СоздатьКаталог(ИмяКаталогаВременныхФайлов);
	
	ФайлЛогаUI = Новый Файл(ИмяКаталогаВременныхФайлов + "\log.txt");
	ФайлСОтчетомОТестировании = Новый Файл(ИмяКаталогаВременныхФайлов + "\report.xml");
КонецПроцедуры

Процедура ПослеЗапускаТеста() Экспорт
	Попытка
		УдалитьФайлы(ИмяКаталогаВременныхФайлов);
	Исключение
		// При ошибке удаления временного файла не считаем тест проваленым
	КонецПопытки;
КонецПроцедуры

Процедура ТестДолжен_ПроверитьЗапускВПакетномРежиме_ТолстыйКлиент() Экспорт
	ФайлСТестами = ПолучитьФайлСТестами("Tests\Core\Тесты_СистемаПлагинов.epf");
	СтрокаПараметров = СформироватьСтрокуПараметров("ЗагрузчикФайла", ФайлСТестами, "ГенераторОтчетаJUnitXML");
	
	ВыполнитьПакетныйЗапуск(РежимЗапускаКлиентскогоПриложения.ОбычноеПриложение, СтрокаПараметров);
	
	Ожидаем.Что(ФайлЛогаUI.Существует(), "ФайлЛогаUI").ЭтоИстина();
	Ожидаем.Что(ФайлСОтчетомОТестировании.Существует(), "ФайлСОтчетомОТестировании").ЭтоИстина();
КонецПроцедуры

Функция ПолучитьФайлСТестами(ОтносительныйПуть)
	
	Если КонтекстЯдра.ЭтоВстроеннаяОбработка Тогда
		ФайлЯдра = Новый Файл(ПутьКФайлуПолный);
		ФайлСТестами = Новый Файл(ФайлЯдра.Путь + ОтносительныйПуть);	
	Иначе
		ФайлЯдра = Новый Файл(КонтекстЯдра["ИспользуемоеИмяФайла"]);
		ФайлСТестами = Новый Файл(ФайлЯдра.Путь + ОтносительныйПуть);
	КонецЕсли;
	
	Возврат ФайлСТестами;
КонецФункции

Функция СформироватьСтрокуПараметров(ИдентификаторЗагрузчика, ФайлСТестами, ИдентификаторГенератораОтчета)
	СтрокаПараметров = " /C """ + ПарсерКоманднойСтроки.ВозможныеКлючи.xddRun + " " + ИдентификаторЗагрузчика + " """"" + ФайлСТестами.ПолноеИмя + """"";"
		+ ПарсерКоманднойСтроки.ВозможныеКлючи.xddShutdown + ";"
		+ ПарсерКоманднойСтроки.ВозможныеКлючи.xddReport + " " + ИдентификаторГенератораОтчета + " """"" + ФайлСОтчетомОТестировании.ПолноеИмя +  """"""
		+ """";
	
	Возврат СтрокаПараметров;
КонецФункции

Процедура ВыполнитьПакетныйЗапуск(РежимЗапуска, СтрокаПараметров)
	ПутьКПлатформе1С = ПолучитьПутьКПлатформе1С(РежимЗапуска);
	ВсякиеКлючи = " /Lru /VLru /DisableStartupMessages ";
	СтрокаРежимЗапуска = ПолучитьСтрокаРежимаЗапуска(РежимЗапуска);
	СтрокаСоединения = ПолучитьСтрокуСоединения();
	СтрокаЛогированияUI = " /LogUI /Out """ + ФайлЛогаUI.ПолноеИмя + """";
	
	СтрокаКоманды = """" + ПутьКПлатформе1С + """";
	СтрокаКоманды = СтрокаКоманды + ВсякиеКлючи;
	СтрокаКоманды = СтрокаКоманды + СтрокаРежимЗапуска;
	СтрокаКоманды = СтрокаКоманды + СтрокаСоединения;
	СтрокаКоманды = СтрокаКоманды + " /Execute " + КонтекстЯдра["ИспользуемоеИмяФайла"];
	СтрокаКоманды = СтрокаКоманды + СтрокаЛогированияUI;
	СтрокаКоманды = СтрокаКоманды + СтрокаПараметров;
	
	ЗапуститьПриложение(СтрокаКоманды, , Истина);
КонецПроцедуры

Функция ПолучитьПутьКПлатформе1С(РежимЗапуска)
	Если РежимЗапуска = РежимЗапускаКлиентскогоПриложения.УправляемоеПриложение Тогда
		ИмяПрограмы = "1cv8c.exe";
	ИначеЕсли РежимЗапуска = РежимЗапускаКлиентскогоПриложения.ОбычноеПриложение Тогда	
		ИмяПрограмы = "1cv8.exe";
	КонецЕсли;
	ПутьКПлатформе1С = КаталогПрограммы() + ИмяПрограмы;
	
	Возврат ПутьКПлатформе1С;
КонецФункции

Функция ПолучитьСтрокаРежимаЗапуска(РежимЗапуска)
	Перем СтрокаРежимЗапуска;
	Если РежимЗапуска = РежимЗапускаКлиентскогоПриложения.УправляемоеПриложение Тогда
		СтрокаРежимЗапуска = " /RunModeManagedApplication ";
	ИначеЕсли РежимЗапуска = РежимЗапускаКлиентскогоПриложения.ОбычноеПриложение Тогда
		СтрокаРежимЗапуска = " /RunModeOrdinary ";
	КонецЕсли;
	
	Возврат СтрокаРежимЗапуска;
КонецФункции

Функция ПолучитьСтрокуСоединения()
	СтрокаСоединения = СтрокаСоединенияИнформационнойБазы();		
	ПутьКФайловойБазе = НСтр(СтрокаСоединения, "File");
	Если НЕ ПустаяСтрока(ПутьКФайловойБазе) Тогда
		СтрокаСоединения = " /F """ + ПутьКФайловойБазе+"""";
	Иначе
		СтрокаСоединения = " /S " + НСтр(СтрокаСоединения, "Srvr") + "\" + НСтр(СтрокаСоединения, "Ref");
	КонецЕсли;
	ТекущийПользователь = ПользователиИнформационнойБазы.ТекущийПользователь();
	ИмяПользователя = ТекущийПользователь.Имя;
	СтрокаСоединения = СтрокаСоединения + " /N """ + ИмяПользователя + """";
	
	Возврат СтрокаСоединения;
КонецФункции

Процедура ТестДолжен_ПроверитьЗапускВПакетномРежиме_ТонкийКлиент() Экспорт
	ФайлСТестами = ПолучитьФайлСТестами("Tests\Core\Тесты_СистемаПлагинов.epf");
	СтрокаПараметров = СформироватьСтрокуПараметров("ЗагрузчикФайла", ФайлСТестами, "ГенераторОтчетаJUnitXML");
	
	ВыполнитьПакетныйЗапуск(РежимЗапускаКлиентскогоПриложения.УправляемоеПриложение, СтрокаПараметров);
	
	Ожидаем.Что(ФайлСОтчетомОТестировании.Существует(), "ФайлСОтчетомОТестировании существует").ЭтоИстина();
КонецПроцедуры

Процедура ТестДолжен_ПроверитьЗапускВПакетномРежиме_ТолстыйКлиент_СПлохимиПараметрами_xddRun() Экспорт
	ФайлСТестами = ПолучитьФайлСТестами("Tests\Core\Тесты_СистемаПлагинов.epf");
	СтрокаПараметров = СформироватьСтрокуПараметров("НесуществующийЗагрузчик", ФайлСТестами, "ГенераторОтчетаJUnitXML");
	
	ВыполнитьПакетныйЗапуск(РежимЗапускаКлиентскогоПриложения.ОбычноеПриложение, СтрокаПараметров);
	
	Ожидаем.Что(ФайлЛогаUI.Существует(), "ФайлЛогаUI").ЭтоИстина();
	Лог = Новый ЧтениеТекста(ФайлЛогаUI.ПолноеИмя);
	СодержаниеЛога = Лог.Прочитать();
	Ожидаем.Что(СодержаниеЛога, "СодержаниеЛога").Существует();
	Ожидаем.Что(ФайлСОтчетомОТестировании.Существует(), "ФайлСОтчетомОТестировании").ЭтоЛожь();
КонецПроцедуры

Процедура ТестДолжен_ПроверитьЗапускВПакетномРежиме_ТолстыйКлиент_СПлохимиПараметрами_xddReport() Экспорт
	ФайлСТестами = ПолучитьФайлСТестами("Tests\Core\Тесты_СистемаПлагинов.epf");
	СтрокаПараметров = СформироватьСтрокуПараметров("ЗагрузчикФайла", ФайлСТестами, "НесуществующийГенераторОтчета");
	
	ВыполнитьПакетныйЗапуск(РежимЗапускаКлиентскогоПриложения.ОбычноеПриложение, СтрокаПараметров);
	
	Ожидаем.Что(ФайлЛогаUI.Существует(), "ФайлЛогаUI").ЭтоИстина();
	Лог = Новый ЧтениеТекста(ФайлЛогаUI.ПолноеИмя);
	СодержаниеЛога = Лог.Прочитать();
	Ожидаем.Что(СодержаниеЛога, "СодержаниеЛога").Существует();
	Ожидаем.Что(ФайлСОтчетомОТестировании.Существует(), "ФайлСОтчетомОТестировании").ЭтоЛожь();
КонецПроцедуры

Процедура ТестДолжен_ПроверитьЗапускВПакетномРежиме_ТонкийКлиент_СПлохимиПараметрами_xddRun() Экспорт
	ФайлСТестами = ПолучитьФайлСТестами("Tests\Core\Тесты_СистемаПлагинов.epf");
	СтрокаПараметров = СформироватьСтрокуПараметров("НесуществующийЗагрузчик", ФайлСТестами, "ГенераторОтчетаJUnitXML");
	
	ВыполнитьПакетныйЗапуск(РежимЗапускаКлиентскогоПриложения.УправляемоеПриложение, СтрокаПараметров);
	
	Ожидаем.Что(ФайлСОтчетомОТестировании.Существует()).ЭтоЛожь();
КонецПроцедуры

Процедура ТестДолжен_ПроверитьЗапускВПакетномРежиме_ТонкийКлиент_СПлохимиПараметрами_xddReport() Экспорт
	ФайлСТестами = ПолучитьФайлСТестами("Tests\Core\Тесты_СистемаПлагинов.epf");
	СтрокаПараметров = СформироватьСтрокуПараметров("ЗагрузчикФайла", ФайлСТестами, "НесуществующийГенераторОтчета");
	
	ВыполнитьПакетныйЗапуск(РежимЗапускаКлиентскогоПриложения.УправляемоеПриложение, СтрокаПараметров);
	
	Ожидаем.Что(ФайлСОтчетомОТестировании.Существует()).ЭтоЛожь();
КонецПроцедуры
