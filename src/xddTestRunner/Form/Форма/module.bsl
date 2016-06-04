﻿Перем ВстроенаВКонфигурацию Экспорт; // Флаг определяющий встроена ли обработка в состав конфигурации
Перем ЭтоПакетныйЗапуск Экспорт; // Флаг определяет выполнен ли пакетный запуск

// { События формы
Процедура ПриОткрытии()
	
	// Определяем флаг запуска - встроенная или внешняя обработка
	ВстроенаВКонфигурацию = ЭтотОбъект.ЭтоВстроеннаяОбработка();
		
	ЗагрузитьПлагины();
	КэшироватьПеречисленияПлагинов();
	ОбновитьКнопкиИсторииЗагрузкиТестов();
	ЭтаФорма.Заголовок = ЭтотОбъект.ЗаголовокФормы();
	
	ЭтоПакетныйЗапуск = ЗначениеЗаполнено(ПараметрЗапуска);
	Если ЭтоПакетныйЗапуск Тогда
		ВыполнитьПакетныйЗапуск(ПараметрЗапуска);
	Иначе
		ПерезагрузитьПоследниеТестыПоИстории();
	КонецЕсли;
КонецПроцедуры

Процедура ПриЗакрытии()
	ЭтотОбъект.СохранитьНастройки();
	СброситьЦиклическиеСсылки();
КонецПроцедуры

Процедура ОбработатьСобытиеВыполненияТестов(Знач ИмяСобытия, Знач Параметр) Экспорт
     Если ИмяСобытия = ЭтотОбъект.ВозможныеСобытия.ВыполненТестовыйМетод Тогда
		 Если Параметр.Состояние = СостоянияТестов.НеРеализован Тогда
			 Если ЭлементыФормы.ИндикаторВыполнения.ЦветРамки <> WebЦвета.Красный Тогда
				 ЭлементыФормы.ИндикаторВыполнения.ЦветРамки = WebЦвета.Золотой;
			 КонецЕсли;
		 ИначеЕсли Параметр.Состояние = СостоянияТестов.Сломан Тогда
			 ЭлементыФормы.ИндикаторВыполнения.ЦветРамки = WebЦвета.Красный;
		 КонецЕсли;
		 ЭлементыФормы.ИндикаторВыполнения.Значение = ЭлементыФормы.ИндикаторВыполнения.Значение + 1;
     КонецЕсли;
КонецПроцедуры
// } События формы

// { Управляющие воздействия пользователя
Процедура КнопкаВыполнитьВсеТестыНажатие(Элемент)
	ВыполнитьТестыНаКлиенте();
КонецПроцедуры

Процедура ВыполнитьТестыНаКлиенте(Знач Фильтр = Неопределено)
	Если ЗначениеЗаполнено(ЭтаФорма.ДеревоОтЗагрузчика) Тогда
		ОчиститьСообщения();
		
		КоличествоТестовыхМетодов = ЭтотОбъект.ПолучитьКоличествоТестовыхМетодов(ЭтаФорма.ДеревоОтЗагрузчика, Фильтр);
		ИнициализироватьИндикаторВыполнения(КоличествоТестовыхМетодов);
		
		РезультатыТестирования = ВыполнитьТесты(ЭтаФорма.Загрузчик, ЭтаФорма.ДеревоОтЗагрузчика, Фильтр, ЭтаФорма);
		
		ОбновитьДеревоТестовНаОснованииРезультатовТестирования(ДеревоТестов.Строки[0], РезультатыТестирования);
		
		ГенераторОтчетаMXL = Плагин("ГенераторОтчетаMXL");
		Отчет = ГенераторОтчетаMXL.СоздатьОтчет(ЭтотОбъект, РезультатыТестирования);
		ГенераторОтчетаMXL.Показать(Отчет);
	КонецЕсли;
КонецПроцедуры

Процедура КнопкаВыполнитьВыделенныеТестыНажатие(Элемент)
	Фильтр = Новый Массив;
	ВыделенныеСтроки = ЭлементыФормы.ДеревоТестов.ВыделенныеСтроки;
	Для каждого ВыделеннаяСтрока Из ВыделенныеСтроки Цикл
		Фильтр.Добавить(Новый УникальныйИдентификатор(ВыделеннаяСтрока.Ключ));
	КонецЦикла;
	Если Фильтр.Количество() > 0 Тогда
		ВыполнитьТестыНаКлиенте(Фильтр);
	КонецЕсли;
КонецПроцедуры

Процедура КнопкаЗагрузитьТестыНажатие(Элемент)
	ЗагрузчикПоУмолчанию = ЭтотОбъект.ЗагрузчикПоУмолчанию();
	ИдентификаторЗагрузчикаПоУмолчанию = ЗагрузчикПоУмолчанию.ОписаниеПлагина(ЭтотОбъект.ТипыПлагинов).Идентификатор;
	Подключаемый_ИнтерактивныйВызовЗагрузчика(Новый Структура("Имя", ИдентификаторЗагрузчикаПоУмолчанию));
КонецПроцедуры

Процедура КнопкаПерезагрузитьПерезагрузитьБраузерТестирования(Кнопка)

	Для каждого МетаФорма Из ЭтаФорма.Метаданные().Формы Цикл
		ТекФорма = ПолучитьФорму(МетаФорма); // может возвращать неопределено, если есть управляемая форма
		Если ТекФорма <> Неопределено И ТекФорма.Открыта() Тогда
			СброситьЦиклическиеСсылки();
			ТекФорма.Закрыть();
			Если ТекФорма = ЭтаФорма Тогда
				НайденноеИмяФайла = Неопределено;
				// Для встроенного в состав конфигурации браузера тестов
				// открываем форму обработки заново
				Если ВстроенаВКонфигурацию Тогда
					ЭтотОбъект.ПолучитьФорму(МетаФорма.Имя).Открыть();	
				Иначе
					Выполнить("НайденноеИмяФайла = ЭтотОбъект.ИспользуемоеИмяФайла;");
					ВнешниеОбработки.Создать(НайденноеИмяФайла, Ложь).ПолучитьФорму(МетаФорма.Имя).Открыть();
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

Процедура СброситьЦиклическиеСсылки()
	ЭтотОбъект.Плагины = Неопределено;
	Загрузчик = Неопределено;
КонецПроцедуры

Процедура ПерезагрузитьПоследниеТестыПоИстории(Элемент = Неопределено)
	ИсторияЗагрузкиТестов = ЭтотОбъект.Настройки.ИсторияЗагрузкиТестов;
	Если ИсторияЗагрузкиТестов.Количество() > 0 Тогда
		ЭлементИстории = ИсторияЗагрузкиТестов[0];
		Попытка
			ЗагрузитьТесты(ЭлементИстории.ИдентификаторЗагрузчика, ЭлементИстории.Путь);
		Исключение
			// TODO
			Сообщить("Не удалось загрузить тесты из истории <" + ЭлементИстории.ИдентификаторЗагрузчика + ": " + ЭлементИстории.Путь + ">" + Символы.ПС + ОписаниеОшибки());
		КонецПопытки;
	КонецЕсли;
КонецПроцедуры

Процедура КнопкаИнструментыГенераторМакетовДанных(Кнопка)
	ОткрытьИнструмент("СериализаторMXL", ПолучитьПутьКПлагинам());
КонецПроцедуры

Процедура КнопкаИнструментыПоказатьГУИД(Кнопка)
	ОткрытьИнструмент("xddGuidShow");
КонецПроцедуры

Процедура КнопкаИнструментыКонвертерТестов(Кнопка)
	ОткрытьИнструмент("xddTestsConvertIntoRebornFormat");
КонецПроцедуры
// } Управляющие воздействия пользователя

// { Плагины
Процедура ЗагрузитьПлагины()
	ЭтотОбъект.Плагины = Новый Структура;
	
	// Если браузер тестов встроен в состав конфигурации, то плагины
	// получаем из встроеной подсистемы xUnitFor1C.Plugins
	Если ВстроенаВКонфигурацию Тогда
		ЭтотОбъект.Плагины = ЭтотОбъект.ПолучитьПлагины();
	Иначе
		КаталогПлагинов = ПолучитьПутьКПлагинам();
		НайденныеФайлы = НайтиФайлы(КаталогПлагинов, "*.epf", Ложь);
		Для каждого ФайлОбработки Из НайденныеФайлы Цикл
			Обработка = ВнешниеОбработки.Создать(ФайлОбработки.ПолноеИмя, Ложь);
			Попытка
				ОписаниеПлагина = Обработка.ОписаниеПлагина(ЭтотОбъект.ТипыПлагинов);
				Обработка.Инициализация(ЭтотОбъект);
				ЭтотОбъект.Плагины.Вставить(ОписаниеПлагина.Идентификатор, Обработка);
			Исключение
				Ошибка = "Возникла ошибка при загрузке плагина: "+ФайлОбработки.Имя + Символы.ПС + ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
				Сообщить(Ошибка);
				Продолжить;
			КонецПопытки;
		КонецЦикла;
	КонецЕсли;
	
	ДобавитьКомандыЗагрузчиковНаФорме();
КонецПроцедуры

Процедура КэшироватьПеречисленияПлагинов()
	ЭтотОбъект.ТипыУзловДереваТестов = Плагин("ПостроительДереваТестов").ТипыУзловДереваТестов;
КонецПроцедуры

Процедура ДобавитьКомандыЗагрузчиковНаФорме()
	ОписанияЗагрузчиков = ЭтотОбъект.ПолучитьОписанияПлагиновПоТипу(ЭтотОбъект.ТипыПлагинов.Загрузчик);
	Меню = ЭлементыФормы.КнопкаЗагрузитьТесты.Кнопки;
	
	ИндексКнопки = 0;
	Для каждого ОписаниеПлагина Из ОписанияЗагрузчиков Цикл
		НоваяКнопка = Меню.Вставить(ИндексКнопки, ОписаниеПлагина.Идентификатор, ТипКнопкиКоманднойПанели.Действие, ОписаниеПлагина.Представление, Новый Действие("Подключаемый_ИнтерактивныйВызовЗагрузчика"));
		ИндексКнопки = ИндексКнопки + 1;
	КонецЦикла;
	НоваяКнопка = Меню.Вставить(ИндексКнопки, "", ТипКнопкиКоманднойПанели.Разделитель);
КонецПроцедуры
// } Плагины

// { Работа с деревом тестов
Процедура Подключаемый_ИнтерактивныйВызовЗагрузчика(Кнопка)
	ИдентификаторЗагрузчика = Кнопка.Имя;
	Путь = ЭтотОбъект.Плагин(ИдентификаторЗагрузчика).ВыбратьПутьИнтерактивно();
	Если ЗначениеЗаполнено(Путь) Тогда
		ЗагрузитьТесты(ИдентификаторЗагрузчика, Путь);
	КонецЕсли;
КонецПроцедуры 

Процедура ЗагрузитьТесты(Знач ИдентификаторЗагрузчика, Знач Путь)
	ИнициализироватьИндикаторВыполнения();
	
	ЭтаФорма.Загрузчик = ЭтотОбъект.Плагин(ИдентификаторЗагрузчика);
	
	Попытка
		ЭтаФорма.ДеревоОтЗагрузчика = ЭтаФорма.Загрузчик.Загрузить(ЭтотОбъект, Путь);
	Исключение
		Сообщить(ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		Возврат;
	КонецПопытки;
	
	ДеревоТестов.Строки.Очистить();
	ЗаполнитьДеревоТестов(ДеревоТестов, ДеревоОтЗагрузчика);
	
	КоличествоТестовыхСлучаев = ЗаполнитьКоличествоТестовыхСлучаевПоВсемуДеревуТестов(ДеревоТестов);
	РазвернутьСтрокиДерева(КоличествоТестовыхСлучаев < 30);
	
	ЭтотОбъект.СохранитьВИсториюЗагрузкиТестов(ИдентификаторЗагрузчика, Путь);
	ОбновитьКнопкиИсторииЗагрузкиТестов();
КонецПроцедуры

Процедура ЗаполнитьДеревоТестов(РодительскаяСтрокаДереваТестов, Знач КонтейнерДереваТестовЗагрузчика)
	СтрокаКонтейнера = РодительскаяСтрокаДереваТестов.Строки.Добавить();
	СтрокаКонтейнера.Имя = КонтейнерДереваТестовЗагрузчика.Имя;
	СтрокаКонтейнера.ИконкаУзла = КонтейнерДереваТестовЗагрузчика.ИконкаУзла;
	СтрокаКонтейнера.Ключ = КонтейнерДереваТестовЗагрузчика.Ключ;
	
	Для каждого ЭлементКоллекции Из КонтейнерДереваТестовЗагрузчика.Строки Цикл
		Если ЭлементКоллекции.Тип = ЭтотОбъект.ТипыУзловДереваТестов.Контейнер Тогда
			ЗаполнитьДеревоТестов(СтрокаКонтейнера, ЭлементКоллекции);
		ИначеЕсли ЭлементКоллекции.Тип = ЭтотОбъект.ТипыУзловДереваТестов.Элемент Тогда
			СтрокаЭлемента = СтрокаКонтейнера.Строки.Добавить();
			СтрокаЭлемента.Имя = ЭлементКоллекции.Представление;
			СтрокаЭлемента.Путь = ЭлементКоллекции.Путь;
			СтрокаЭлемента.ИконкаУзла = ЭлементКоллекции.ИконкаУзла;
			СтрокаЭлемента.Ключ = ЭлементКоллекции.Ключ;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

Функция ЗаполнитьКоличествоТестовыхСлучаевПоВсемуДеревуТестов(РодительскаяСтрока)
	КоллекцияСтрок = РодительскаяСтрока.Строки;
	Если КоллекцияСтрок.Количество() = 0 Тогда
		Возврат 1;
	КонецЕсли;
	ОбщееКоличествоТестов = 0;
	Для каждого СтрокаДерева из КоллекцияСтрок Цикл
		КоличествоТестовВСтроке = ЗаполнитьКоличествоТестовыхСлучаевПоВсемуДеревуТестов(СтрокаДерева);
		СтрокаДерева.КоличествоТестов = КоличествоТестовВСтроке;
        ОбщееКоличествоТестов = ОбщееКоличествоТестов + КоличествоТестовВСтроке;
	КонецЦикла;
	
	Возврат ОбщееКоличествоТестов;
КонецФункции

Процедура РазвернутьСтрокиДерева(Знач ВключаяПодчиненные = Ложь)
	Для каждого СтрокаДерева из ДеревоТестов.Строки Цикл
		ЭлементыФормы.ДеревоТестов.Развернуть(СтрокаДерева, ВключаяПодчиненные);
	КонецЦикла;
КонецПроцедуры

Процедура ОбновитьДеревоТестовНаОснованииРезультатовТестирования(УзелДереваТестов, Знач РезультатТестирования)
	УзелДереваТестов.Состояние = РезультатТестирования.Состояние;
	УзелДереваТестов.ВремяВыполнения = РезультатТестирования.ВремяВыполнения;
	Если РезультатТестирования.Тип = ЭтотОбъект.ТипыУзловДереваТестов.Контейнер Тогда
		Для каждого ДочернийРезультатТестирования Из РезультатТестирования.Строки Цикл
			ДочернийУзелДереваТестов = УзелДереваТестов.Строки.Найти(Строка(ДочернийРезультатТестирования.Ключ), "Ключ");
			ОбновитьДеревоТестовНаОснованииРезультатовТестирования(ДочернийУзелДереваТестов, ДочернийРезультатТестирования);
		КонецЦикла;
	ИначеЕсли РезультатТестирования.Тип = ЭтотОбъект.ТипыУзловДереваТестов.Элемент Тогда
		Если РезультатТестирования.Свойство("Сообщение") И ЗначениеЗаполнено(РезультатТестирования.Сообщение) Тогда
			Сообщить(РезультатТестирования.Сообщение, СтатусСообщения.ОченьВажное);
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры
// } Работа с деревом тестов

// { История загрузки тестов
Процедура ОбновитьКнопкиИсторииЗагрузкиТестов()
	ИсторияЗагрузкиТестов = ЭтотОбъект.Настройки.ИсторияЗагрузкиТестов;
	МенюИсторияЗагрузкиТестов = ЭтаФорма.ЭлементыФормы.КнопкаЗагрузитьТесты.Кнопки.ИсторияЗагрузкиТестов.Кнопки;
	Для Сч = 0 По ИсторияЗагрузкиТестов.Количество() - 1 Цикл
		ИмяКнопки = "История_" + Сч;
		ЭлементИстории = ИсторияЗагрузкиТестов[Сч];
		ТекстКнопки = ЭлементИстории.ИдентификаторЗагрузчика + ": " + ЭлементИстории.Путь;
		Кнопка = МенюИсторияЗагрузкиТестов.Найти(ИмяКнопки);
		Если Кнопка = Неопределено Тогда
			Кнопка = МенюИсторияЗагрузкиТестов.Добавить(ИмяКнопки, ТипКнопкиКоманднойПанели.Действие, , Новый Действие("Подключаемый_ЗагрузитьТестыИзИстории"));
		КонецЕсли;
		Кнопка.Текст = ТекстКнопки;
	КонецЦикла;
КонецПроцедуры

Процедура Подключаемый_ЗагрузитьТестыИзИстории(Кнопка)
	ИндексИстории = Число(Сред(Кнопка.Имя, Найти(Кнопка.Имя, "_") + 1));
	ИсторияЗагрузкиТестов = ЭтотОбъект.Настройки.ИсторияЗагрузкиТестов;
	ЭлементИстории = ИсторияЗагрузкиТестов[ИндексИстории];
	ЗагрузитьТесты(ЭлементИстории.ИдентификаторЗагрузчика, ЭлементИстории.Путь);
КонецПроцедуры
// } История загрузки тестов

// { Пакетный запуск
Процедура ВыполнитьПакетныйЗапуск(Знач ПараметрЗапуска)
	Перем РезультатыТестирования;
	
	ПарсерКоманднойСтроки = ЭтотОбъект.Плагин("ПарсерКоманднойСтроки");
	ПараметрыЗапуска = ПарсерКоманднойСтроки.Разобрать(ПараметрЗапуска);
	
	Параметры_xddRun = Неопределено;
	Если ПараметрыЗапуска.Свойство(ПарсерКоманднойСтроки.ВозможныеКлючи.xddRun, Параметры_xddRun) Тогда
		РезультатыТестирования = ЗагрузитьИВыполнитьТесты_ПакетныйРежим(Параметры_xddRun);
	КонецЕсли;
	
	Параметры_xddReport = Неопределено;
	Если ЗначениеЗаполнено(РезультатыТестирования) И ПараметрыЗапуска.Свойство(ПарсерКоманднойСтроки.ВозможныеКлючи.xddReport, Параметры_xddReport) Тогда
		СформироватьОтчетОТестированииИЭкспортировать_ПакетныйРежим(Параметры_xddReport, РезультатыТестирования);
	КонецЕсли;
	
	Если ПараметрыЗапуска.Свойство(ПарсерКоманднойСтроки.ВозможныеКлючи.xddShutdown) Тогда
		ЗавершитьРаботуСистемы(Ложь);
	КонецЕсли;
КонецПроцедуры

Функция ЗагрузитьИВыполнитьТесты_ПакетныйРежим(Знач Параметры_xddRun)
	Попытка
		ИдентификаторЗагрузчика = Параметры_xddRun[0];
		Загрузчик = ЭтотОбъект.Плагин(ИдентификаторЗагрузчика);
		
		ПутьКТестам = Параметры_xddRun[1];
		ДеревоТестовОтЗагрузчика = Загрузчик.Загрузить(ЭтотОбъект, ПутьКТестам);
		
		РезультатыТестирования = ЭтотОбъект.ВыполнитьТесты(Загрузчик, ДеревоТестовОтЗагрузчика);
	Исключение
		ОписаниеОшибки = ОписаниеОшибки();
		Сообщить(ОписаниеОшибки, СтатусСообщения.ОченьВажное);
	КонецПопытки;
	
	Возврат РезультатыТестирования;
КонецФункции

Процедура СформироватьОтчетОТестированииИЭкспортировать_ПакетныйРежим(Знач Параметры_xddReport, Знач РезультатыТестирования)
	Попытка
		ИдентификаторГенератораОтчета = Параметры_xddReport[0];
		ГенераторОтчета = ЭтотОбъект.Плагин(ИдентификаторГенератораОтчета);
		Отчет = ГенераторОтчета.СоздатьОтчет(ЭтотОбъект, РезультатыТестирования);
		ПутьКОтчету = Параметры_xddReport[1];
		ГенераторОтчета.Экспортировать(Отчет, ПутьКОтчету);
	Исключение
		ОписаниеОшибки = ОписаниеОшибки();
		Сообщить(ОписаниеОшибки, СтатусСообщения.ОченьВажное);
	КонецПопытки;
КонецПроцедуры
// } Пакетный запуск

// { Внешние интерфейстные инструменты
Процедура ОткрытьИнструмент(Знач ИмяИнструмента, Знач ПутьИнструмента = "", Знач ИмяФормы = "Форма")
	// Если браузер тестов встроен в конфигурацию, то обработки инструментов
	// получаем также из состава конфигурации
	Если ВстроенаВКонфигурацию Тогда
		// Преобразование имени инструмента к имени обработки
		Если ИмяИнструмента = "UILogToScript" Тогда
			ИмяИнструмента = "ПреобразованиеЖурналаДействийПользователя";
		КонецЕсли;
		НоваяФорма = ПолучитьФорму("Обработка." + ИмяИнструмента + "." + ИмяФормы);	
	Иначе
		Если Не ПустаяСтрока(ПутьИнструмента) Тогда
			ПутьКВнешнимИнструментам = ПутьИнструмента + "\";
		Иначе
			ПутьКВнешнимИнструментам = ПолучитьПутьКВнешнимИнструментам();
		КонецЕсли;
		ПутьИнструмента = ПутьКВнешнимИнструментам + ИмяИнструмента + ".epf";
		ФайлИнструмента = Новый Файл(ПутьИнструмента);
		Если Не ФайлИнструмента.Существует() Тогда
			Сообщить("Инструмент <" + ИмяИнструмента + "> не найден в каталоге <" + ФайлИнструмента.Путь + ">");
			Возврат;
		КонецЕсли;
		Обработка = ВнешниеОбработки.Создать(ФайлИнструмента.ПолноеИмя, Ложь);
		НоваяФорма = Обработка.ПолучитьФорму(ИмяФормы);
		Если НоваяФорма = Неопределено Тогда
			Сообщить("Инструмент <" + ИмяИнструмента + ">: не удалось получить основную форму!");
			Возврат;
		КонецЕсли;
	КонецЕсли;
	НоваяФорма.Открыть();
	НоваяФорма = Неопределено;
КонецПроцедуры

Функция ПолучитьПутьКПлагинам()
	// Для встроенной в состав конфигурации обработки
	// имя используемого файла не получаем, т.к. плагины 
	// получаются из встроенной подсистемы
	Если НЕ ВстроенаВКонфигурацию Тогда
		ФайлЯдра = Новый Файл(ЭтаФорма["ИспользуемоеИмяФайла"]);
		Результат = ФайлЯдра.Путь + "Plugins\";
	КонецЕсли;
	
	Возврат Результат;
КонецФункции

Функция ПолучитьПутьКВнешнимИнструментам()
	ФайлЯдра = Новый Файл(ЭтотОбъект.ИспользуемоеИмяФайла);
	Результат = ФайлЯдра.Путь + "Utils\";
	
	Возврат Результат;
КонецФункции
// } Внешние интерфейстные инструменты

Процедура ИнициализироватьИндикаторВыполнения(Знач КоличествоТестовыхМетодов = 0)
	ЭлементыФормы.ИндикаторВыполнения.МаксимальноеЗначение = КоличествоТестовыхМетодов;
	ЭлементыФормы.ИндикаторВыполнения.Значение = 0;
	ЭлементыФормы.ИндикаторВыполнения.ЦветРамки = Новый Цвет(0, 174, 0); // Зеленый
КонецПроцедуры
