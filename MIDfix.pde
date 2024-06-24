import processing.serial.*;
import cc.arduino.*;
import java.util.ArrayList;
import java.util.Properties;
import java.io.*;
import ddf.minim.*;

Minim minim;
AudioPlayer player;
AudioPlayer sound_lobby,sound_game,sound_correct,sound_incorrect,sound_result;

PFont chineseFont; // 創建一個PFont物件
PFont numberFont;
PGraphics buffer;
PGraphics buffer2;
// 數據結構包含多個問題和答案
String[][] questionsAndAnswers = {
    {"下列哪個選項最能描述SDG 2的目標？", 
     "減少食物浪費", "提高農作物產量", "消除全球饑餓", "促進食物安全管理", "3"},
    
    {"SDGs的目標是什麼時候被提出？",
     "2000年", "2015年", "2020年", "2025年", "2"},
    
    {"預計於哪一年完成SDGs目標 ?",
     "2020年", "2025年", "2030年", "2035年", "3"},
    
    {"下列哪個不是SDG 2的重要目標之一？",
     "增加農產品出口", "提高農民收入", "減少全球饑餓", "促進可持續農業", "3"},
    
    {"SDG 2的實現需要哪些行動？",
     "政府政策改革", "社會組織合作", "國際合作與資源投入", "個人態度改變", "3"},
    
    {"下列哪個行動最能促進SDG 2的實現？",
     "推廣快餐文化", "減少食物生產", "提高農業生產效率", "加強城市化發展", "3"},
    
    {"SDG 2的主要目標之一是保障全球人民具有什麼權利？",
     "旅行自由", "飲食權", "健康權", "食品安全與營養權", "4"},
    
    {"消除飢餓是SDG多少?",
     "5", "11", "7", "2", "4"},
    
    {"SDG 2的目標之一是提高農業生產性和農業收入，這受到哪種因素的影響最大？",
     "文化因素", "政府開支", "氣候變遷", "都市規劃", "3"},
    
    {"以下哪種行為能協助達成 SDG 2？",
     "累積物資，形成需求過剩", "尊重食物，減少食物浪費", "頻繁更換農作物種植地點","過度開發地下水源", "2"}
};

String[][] questionsAndAnswers4 = {
    {"誰負責實現永續發展目標？", "大人", "每個人", "政治人物", "科學家","2"},
    {"SDG 4的其中一項目標是為了實現什麼？", "提供資源給所有教師", "減輕教育資源負擔", "透過教育促進和平與可持續發展全球公民的文化", "根據學生需求創立新教育系統","3"},
    {"SDG 4的目標之一是確保所有孩子都能在何種學習環境下學習生活必須的知識？", "安全，無暴力，包容和有效的學習環境", "自我開發的學習環境", "大眾媒體的學習環境", "嚴格控制的學習環境","1"},
    {"以下哪項因素對實現可持續教育有重大影響？", "國際關係政策", "國際貿易情勢", "教育投資和教師的資源提供", "網路發展趨勢","3"},
    {"哪一項不是實現SDG 4的具體策略？", "確保所有學生的學習機會", "打造有效的學業領域和學習環境", "提升教育的投資與支源", "立即停辦所有學校","4"},
    {"聯合國的SDG 4主要目標是哪一項", "終結貧困", "確保優質教育及終身學習機會", "實現性別平等", "保護海洋生態","2"},
    {"SDG 4提出的主要挑戰是什麼？", "加強國際貿易", "提高經濟增長率", "提供包容而且平等的教育機會", "減少全球溫室氣體排放","3"},
    {"以下哪種行為不協助達成 SDG 4？", "建立與維護教育設施", "提供安全無暴力的學習環境", "建立與維護教育設施降低女孩和婦女的學習機會", "提高全球學生的讀寫和算數能力","3"},
    {"聯合國於 2015 年提出SDGs，指引全球共同努力、 邁向永續。下列哪一項不屬於 SDGs 的範圍？", "健康與福祉", "改善網路品質與公平", "責任消費及生產", "和平、正義及健全制度","2"},
    {"「SDGs」是由哪個國際組織公布的？", "UN", "WTO", "WHO", "UNESCO","1"}
};

String[][] questionsAndAnswers12 = {
    {"SDG 12 的目標是什麼？", "氣候行動", "責任的消費與生產", "淨水及衛生", "和平、正義及健全制度","2"},
    {"SDG 12希望透過哪種方式實現負責任的消費？", "鼓勵過度消費", "提倡再生能源使用", "建立廢品焚化設施", "頻繁更換消費商品","2"},
    {"哪一項不是屬於實現SDG 12的措施？", "制定可持續和負責任的消費政策", "鼓勵企業以可持續的方式提供貨物和服務", "教育消費者對負責任消費的重要性", "鼓勵使用非可再生資源","4"},
    {"SDG 12要透過以下哪種方式減少全球食品浪費?", "提供良好的環境教育", "建立健全的食品回收系統", "限制市民購買食品的數量", "取消學校供餐制度","2"},
    {"SDG 12的其中一項目標是？", "到 2020年，確保所有地區都有機會接受環保教育", "到 2020年，完全禁止化石燃料使用", "到 2020年，提供可維持生活的最低工資", "到 2020年，實現對化學物質及所有廢棄物的環境合理管理","4"},
    {"以下哪種行為協助達成 SDG 12？", "將剩菜剩飯全部丟掉", "購買大量不需要的商品", "大量使用塑膠商品", "能源有效地使用和選擇環保產品","4"},
    {"以下哪項因素對實現負責任的消費與生產有重大影響？", "國際貿易情勢", "國際關係政策", "企業的環保意識和消費者的消費觀念", "嚴格的學校制度","3"},
    {"SDG 12的其中一項目標是為了達到什麼？", "減輕資源負擔", "提供資源給所有消費者", "鼓勵企業和消費者進行更為永續的實踐", "使所有國家的資源使用達到同等程度","3"},
    {"SDG 12的目標在於：", "建立良好的全球貿易體系", "促進無條件消費", "鼓勵在大型連鎖店購物", "使消費和生產模式達到可持續發展","4"},
    {"SDG 12的其中一項目標是？", "2030年前，將零售和消費者方面的全球人均糧食浪費減半，並減少生產與供應鏈上的糧食損失，包括收割後損失。", "2030年前，完全禁止化石燃料使用", "2030年前，提供可維持生活的最低工資", "2030年前，實現對化學物質及所有廢棄物的環境合理管理","1"}
};

String[][] questionsAndAnswers13 = {
    {"SDG 13的主要目標是哪一項？", "終結全球貧困", "建立和諧的全球夥伴關係", "採取緊急行動來對抗氣候變遷及其影響", "確保所有人都能享有清潔和衛生的水和衛生設施","3"},
    {"SDG 13的主要挑戰是什麼？", "消除全球飢餓", "保護海洋及其資源的可持續利用", "對抗全球氣候變遷及其影響", "禁止所有的貧困和暴力行為","3"},
    {"哪一項不是對抗全球氣候變遷的具體策略？", "提高能源效率", "發展再生能源", "加強氣候變遷的適應能力", "大量製造和使用一次性塑膠產品","4"},
    {"SDG 13希望努力實現哪項具體目標？", "每人每天飲用至少8杯水", "所有人都有機會學習新的語言", "提高全球對於氣候變遷的意識並加強能力以對抗氣候變遷的影響", "每個孩子都能接受至少12年的免費與優質教育","3"},
    {"哪項行為不符合SDG 13的理念？", "節能減碳", "種植樹木以吸收二氧化碳", "保護並恢復自然生態系統", "大量開採化石燃料","4"},
    {"於哪年196個締約國在聯合國第21屆氣候變遷大會上同意採納《巴黎協定》？", "2015年", "2016年", "2017年", "2018年","1"},
    {"《巴黎協定》主要目標為何？", "以工業革命前的水平為基準，將全球平均升溫控制在2°C 內", "以工業革命前的水平為基準，將全球平均升溫控制在2.5°C 內", "以工業革命前的水平為基準，將全球平均升溫控制在1.5°C 內", "以工業革命前的水平為基準，將全球平均升溫控制在0.5°C 內","1"},
    {"有關SDG 13正確的是：", "提升全球人均年收入", "達到零饑餓，確保所有人都有足夠的食物", "達成永續的城市和社區，讓所有人都有安全的居住地", "2020年前，每年從各來源募得一千億美元，針對開發中國家需求，進行有意義且透明的減災行動","4"},
    {"SDG 13的其中一項目標是為了什麼？", "提高全球溫度至1.5°C以上", "保持全球溫度的增加在2°C以下並努力將增幅維持在1.5°C以下", "使所有國家都實現工業化", "減少全球資源的使用和消耗量","2"},
    {"SDG 13的主要目標之一是保護什麼？", "大氣層", "海洋生態", "氣候系統", "地球內核","3"}
};
//改的
PImage[] Theme1 = new PImage[10];
PImage[] Theme2 = new PImage[10];
PImage[] Theme3 = new PImage[10];
PImage[] Theme4 = new PImage[10];

//ARDUNIO
Arduino arduino;

PImage mouseIcon; 

int xPin = 0;  //X軸 接類比A0
int yPin = 1;  //Y軸 接類比A1
int zPin = 2;  //Z軸 接類比A2

int xval=0;    //Ｘ軸變數
int yval=0;    //Ｙ軸變數
int zval=0;    //Ｚ軸變數

int cosmouseX = 0;
int cosmouseY = 900;
int speed = 10;
//起始畫面
PImage bg;
String title = "knowledge challenging !";
PFont font;
boolean isstart = true; //追蹤是否為起始畫面

int maxLevel = 10; // 最高等級
int[] levelExp = {0, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000}; // 每個等級所需的經驗值

PImage[] levelIcons = new PImage[maxLevel + 1]; // 存儲每個等級的圖標

//關卡選擇
PImage bgselect;
String titleselect = "LEVEL  SELECTION";
boolean isselect = false; //追蹤是否為關卡選擇
//題目
int question = 0; //看要用哪個題目
String filePath = "savedata.txt";

String[] options; // 選項陣列
ArrayList<int []> WrongQuestionSave = new ArrayList<>(); //錯題陣列
int countwrong = 0;

int currentQuestionIndex = 0; // 當前題目的索引，從0開始
int correctOptionIndex = 5; // 正確答案的索引，即數據結構中的最後一個元素
boolean isTimeOut = false;//跟蹤是否到時了

boolean isanswerCorrect = false; // 跟蹤是否答對了
boolean isanswerWrong = false; // 跟蹤是否答錯了

boolean canPressButton = true;//可不可以按按鈕
boolean isfirst = false;//用來清第一次而已

int startTimeSave; // 倒計時開始的時間
int countdownDuration = 10; // 倒計時持續時間，單位：秒
int elapsedTime; //正數計時

String correctAnswer = "";
int temp = 0;
boolean isone = false;

// 按鈕大小
float w = 820;
float h = 40;
  
int Score = 0; //分數
int numCorrect = 0; //正確答案數
int TotalTime = 0;

boolean isCheckWrong = false; //是否檢查錯題
//結算
String filePath3 = "bool.txt";
ArrayList<Boolean> booleanList = new ArrayList<>();
int value1 = 400; // 第一個長條的值
int value2 = 500; // 第二個長條的值
PImage coin;      //金幣
PImage exp;       //經驗值
PImage sun;
//計算答對題目的金幣及經驗獲得
int maxCoins = 30;
int maxExps = 100;
int totalQuestions = 10;
int totalCoin = 0;//總金錢
int totalExp = 0; //總經驗
int MaxExp = 1000; //經驗上限

ArrayList<Integer> HighScore = new ArrayList<>(); 
String variableName = "";
boolean isWriteCoin = false;
boolean isWriteExp = false;
boolean isWriteScore= false;
boolean isWriteBool = false;
String filePath2 = "savescore.txt";

//商店
PImage coinx2;
PImage expx2;
PImage store;
PImage scaledImg;

boolean coinClicked = false;
boolean expClicked = false;

int requiredCoins = 50; // 購買所需金幣量

PFont myFont;

boolean isshop = false; //追蹤是否為商店

void setup() {
  size(1680, 900);
  //讀取歷史
   // 從檔案中讀取變數名稱和值
        String readVariableName = "";
        String readVariableName2 = "";
        int readCoin = 0;
        int readExp = 0;
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line = reader.readLine();
            if (line != null) {
                String[] parts = line.split("=");
                readVariableName = parts[0];
                readCoin = Integer.parseInt(parts[1]);
                totalCoin = readCoin;
                System.out.println("已成功從檔案中讀取變數名稱：" + readVariableName + "，值：" + readCoin);
                line = reader.readLine();
                if (line != null) {
                  String[] parts2 = line.split("=");
                  readVariableName2 = parts2[0];
                  readExp = Integer.parseInt(parts2[1]);
                  totalExp = min(readExp,MaxExp);
                  System.out.println("已成功從檔案中讀取變數名稱：" + readVariableName2 + "，值：" + readExp);
                }
            } else {
                System.out.println("檔案為空，無法讀取變數名稱和值。");
            }
        } catch (IOException | NumberFormatException | ArrayIndexOutOfBoundsException e) {
            System.out.println("讀取檔案時發生錯誤：" + e.getMessage());
        }
        
    // 從檔案中讀取變數名稱和值
    Properties readProperties = new Properties();
    try (InputStream inputStream = new FileInputStream(filePath2)) {
      // 使用 Properties 的 load() 方法從 inputStream 中讀取變數名稱和值
      readProperties.load(inputStream);
      System.out.println("成功從檔案中讀取變數名稱和值：");
      // 遍歷 Properties 中的所有鍵值對
      for (String key : readProperties.stringPropertyNames()) {
      // 獲取每個鍵對應的值
      String value = readProperties.getProperty(key);
      // 將字符串值轉換為整數
      int numericValue = Integer.parseInt(value);
      // 輸出變數名稱和值
      System.out.println("變數名稱：" + key + "，值：" + numericValue);
      HighScore.add(numericValue);
    }
    } catch (IOException | NumberFormatException e) {
      // 如果發生 IOException 或 NumberFormatException，捕獲異常並輸出錯誤消息
      System.out.println("讀取檔案時發生錯誤：" + e.getMessage());
      HighScore.add(0);
      HighScore.add(0);
      HighScore.add(0);
      HighScore.add(0);
    }
    
    // 讀取文本文件中的布爾值並存儲到 ArrayList 中
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath3))) {
            String line;
            while ((line = reader.readLine()) != null) {
                boolean value = Boolean.parseBoolean(line.trim()); // 將讀取的字串轉換為布爾值
                booleanList.add(value); // 將布爾值添加到 ArrayList 中
            }
            System.out.println("從文件中成功讀取布爾值。");
        } catch (IOException e) {
            System.out.println("讀取文件時發生錯誤：" + e.getMessage());
            for(int i = 0 ; i < 10 ; i++){
              booleanList.add(false);
            }
        }
  
  
  //起始頁面
  // load Image
  loadIcons(); // 加載圖標
  bg=loadImage("bg2.png");
  //load text
  font = loadFont("BerlinSansFBDemi-Bold-48.vlw");
   
  //關卡選擇
  bgselect = loadImage("bg_menu.png");
  
  // 載入支持中文的字型文件
  chineseFont = createFont("微軟正黑體", 16);
  
  numberFont = createFont("Sans Poster Bold 3D JL",36);
  
  // 載入每個主題照片 改

  for (int i = 0; i < 10; i++) {
    Theme1[i] = loadImage("Theme1_" + i + ".jpg");
    Theme2[i] = loadImage("Theme2_" + i + ".jpg");
    Theme3[i] = loadImage("Theme3_" + i + ".jpg");
    Theme4[i] = loadImage("Theme4_" + i + ".jpg");
  }
  
  buffer = createGraphics(1680, 900);
  buffer2 = createGraphics(1680, 900);
  //frameRate(1); 
  // 初始化選項陣列
  options = new String[4];
  // 初始化ardunio
  mouseIcon = loadImage("mouse.png");
   
  arduino = new Arduino(this, Arduino.list()[1], 57600);
  for (int i = 2; i <= 6; i++){
    arduino.pinMode(i, Arduino.INPUT);
  }
  delay(100);//把初始吃掉
  //結算
  sun = loadImage("sun.jpg");
  coin = loadImage("coin.png");
  exp = loadImage("EXP.png");
  //商店
  coinx2 = loadImage("coinx2.png");
  expx2 = loadImage("expx2.png");
  store = loadImage("store.jpg");
  
  scaledImg = createImage((int)(store.width / 1.2), (int)(store.height / 2), RGB);
  scaledImg.copy(store, 0, 0, store.width, store.height, 0, 0, scaledImg.width, scaledImg.height);
  
  // 引入TTF字型
  myFont = createFont("NotoSansTC-SemiBold.ttf", 36);
  textFont(myFont); // 設定字型為粗體TTF字型
  
  // 初始化 Minim
  minim = new Minim(this);
  
  // 載入音樂文件
  player = minim.loadFile("store.mp3");
  
  sound_lobby = minim.loadFile("lobby_music.mp3");
  sound_game = minim.loadFile("game_music.MP3");
  sound_correct = minim.loadFile("correct.MP3");
  sound_incorrect = minim.loadFile("incorrect.MP3");
  sound_result = minim.loadFile("result.MP3");
  
  // 播放音樂
  //player.play();
}

void draw() {
  //background(255);
  textFont(chineseFont);
  //起始
  if(isstart){
    drawstart();  
    custommousemove();
    startbuttonreleased();
  }
  //商店
  else if(isshop){
    drawshop();
    custommousemove(); 
    shopmousePressed();
  }
  //關卡選擇
  else if(isselect){
    drawselect();   
    custommousemove();  
    selectbuttonreleased();
  }
  //回顧錯題
  else if(isCheckWrong && countwrong < WrongQuestionSave.size()){
    String[] currentQuestion = {};
    String currentQuestionText = "";
    /*for (int[] array : WrongQuestionSave) {
    System.out.print("[");
    for (int value : array) {
        System.out.print(value + " ");
    }
    System.out.println("]");   
  }*/
    int index = WrongQuestionSave.get(countwrong)[0];
    currentQuestion = questionsAndAnswers[index];
    currentQuestionText = currentQuestion[0];
    options[0] = currentQuestion[1];
    options[1] = currentQuestion[2];
    options[2] = currentQuestion[3];
    options[3] = currentQuestion[4];
    WrongdrawQuestionAndOptions(currentQuestionText,options);
    switch(question) {
          case 1:
              if(currentQuestionIndex<10){
                  currentQuestion = questionsAndAnswers[currentQuestionIndex];
                  correctAnswer = questionsAndAnswers[index][correctOptionIndex];
                  currentQuestionText = currentQuestion[0];
              }
              break;
          case 2:
              if(currentQuestionIndex<10){
                  currentQuestion = questionsAndAnswers4[currentQuestionIndex];
                  correctAnswer = questionsAndAnswers4[index][correctOptionIndex];
                  currentQuestionText = currentQuestion[0];
              }
              break;
          case 3:
              if(currentQuestionIndex<10){
                  currentQuestion = questionsAndAnswers12[currentQuestionIndex];
                  correctAnswer = questionsAndAnswers12[index][correctOptionIndex];
                  currentQuestionText = currentQuestion[0]; 
              }
              break;
          case 4:
              if(currentQuestionIndex<10){
                  currentQuestion = questionsAndAnswers13[currentQuestionIndex];
                  correctAnswer = questionsAndAnswers13[index][correctOptionIndex];
                  currentQuestionText = currentQuestion[0];
              }
              break;
          default:
              // 當輸入不是0、1或2時執行這裡的程式碼
              break;
          }
    int correctinex = Integer.parseInt(correctAnswer) - 1;
    float buttonX = width/2 - w/2;
    float buttonY = height/4 + 80 + floor(correctinex) * 60;
    if(WrongQuestionSave.get(countwrong)[1] != -1){
       isanswerWrong = true;
       int wrongindex = WrongQuestionSave.get(countwrong)[1];
       float buttonX2 = width/2 - w/2;
       float buttonY2 = height/4 + 80 + floor(wrongindex) * 60;
       WrongdrawButton(buttonX2,buttonY2,options[wrongindex], wrongindex);
    }
    isanswerWrong = false;
    isanswerCorrect = true;
    WrongdrawButton(buttonX,buttonY,options[correctinex], correctinex);
    
    if(arduino.digitalRead(6) == Arduino.LOW){
      delay(1000);
      countwrong += 1;
    }
    
  }else if(isCheckWrong && countwrong >= WrongQuestionSave.size()){
      isCheckWrong = false;
      isstart = true;
      countwrong = 0;
      WrongQuestionSave = new ArrayList<>();
      question = 0;
      rerestart();
      delay(1000);
  }
  //關卡
  else{
      String[] currentQuestion = {};
      String currentQuestionText = "";
      switch(question) {
          case 1:
              if(currentQuestionIndex<10){
                  currentQuestion = questionsAndAnswers[currentQuestionIndex];
                  currentQuestionText = currentQuestion[0];
              }
              break;
          case 2:
              if(currentQuestionIndex<10){
                  currentQuestion = questionsAndAnswers4[currentQuestionIndex];
                  currentQuestionText = currentQuestion[0]; //<>//
              }
              break;
          case 3:
              if(currentQuestionIndex<10){
                  currentQuestion = questionsAndAnswers12[currentQuestionIndex];
                  currentQuestionText = currentQuestion[0]; 
              }
              break;
          case 4:
              if(currentQuestionIndex<10){
                  currentQuestion = questionsAndAnswers13[currentQuestionIndex];
                  currentQuestionText = currentQuestion[0];
              }
              break;
          default:
              // 當輸入不是0、1或2時執行這裡的程式碼
              break;
          }
    if(isanswerCorrect){
        timer(1000);
        sound_correct.rewind();
        sound_correct.pause();
        sound_incorrect.rewind();
        sound_incorrect.pause();
    }
    else if(isanswerWrong){
       timer(1000);
       sound_correct.rewind();
       sound_correct.pause();
       sound_incorrect.rewind();
       sound_incorrect.pause();
    }
    if(currentQuestionIndex<10){
      // 顯示當前問題及選項  
      options[0] = currentQuestion[1];
      options[1] = currentQuestion[2];
      options[2] = currentQuestion[3];
      options[3] = currentQuestion[4];
      drawQuestionAndOptions(currentQuestionText, options);
    }
          
      
    if(currentQuestionIndex == 10){
      drawsettlement();
      endbuttonreleased();
      custommousemove();  
      sound_game.pause();
      //println((TotalTime/1000.0));
    }
    //ardunio
    
    for (int i = 2; i <= 5; i++) {
      //println(arduino.digitalRead(2));
      if (arduino.digitalRead(i) == Arduino.LOW && canPressButton && currentQuestionIndex != 10){
        float buttonX = width/2 - w/2;
        float buttonY = height/4 + 80 + floor(i-2) * 60;
      
        canPressButton = false; 
        selectedOptionIndex = i-2;
        checkAnswer(buttonX,buttonY);
        break;
      }
    }
  }
}

void WrongdrawQuestionAndOptions(String questionText, String[] options) {
  int index2 = WrongQuestionSave.get(countwrong)[0];
  float textWidth = textWidth(questionText);
  float padding = 10;
  // 顯示問題跟分數
  noTint();
  buffer.beginDraw();
  buffer.noTint();
  switch(question){
    case 1:
      buffer.background(255); // 清除緩衝區
      buffer.image(Theme1[index2], 0, 0, width, height);
      break;
    case 2:
      buffer.background(255); // 清除緩衝區
      buffer.image(Theme2[index2], 0, 0, width, height);
      break; 
    case 3:
      buffer.background(255); // 清除緩衝區
      buffer.image(Theme3[index2], 0, 0, width, height);
      break;
    case 4:
      buffer.background(255); // 清除緩衝區
      buffer.image(Theme4[index2], 0, 0, width, height);
      break;
  }
  buffer.fill(255);
  buffer.rectMode(CENTER);
  buffer.rect(width/2, height/4, textWidth * 2 + padding * 2, 20 + padding * 2 , 20);
  buffer.textFont(chineseFont);
  buffer.fill(0); // 設置文字顏色
  buffer.textAlign(CENTER, CENTER);
  buffer.textSize(32);
  buffer.text(questionText, width/2, height/4);//顯示問題
  buffer.endDraw();
  image(buffer, 0, 0); // 一次性將緩衝區渲染到屏幕上
  
  // 顯示選項按鈕
  for (int i = 0; i < options.length; i++) {
    float buttonX = width/2 - w/2;
    float buttonY = height/4 + 80 + floor(i) * 60;
    WrongdrawButton(buttonX, buttonY, options[i], i);
  }
}

void WrongdrawButton(float x, float y, String label, int index) {
  // 檢查滑鼠是否懸停在按鈕上
  int index2 = WrongQuestionSave.get(countwrong)[0];
  //boolean hover = mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
  String correctAnswer = questionsAndAnswers[index2][correctOptionIndex];
  switch(question) {
          case 1:
              if(currentQuestionIndex<10){
                  correctAnswer = questionsAndAnswers[index2][correctOptionIndex];
              }
              break;
          case 2:
              if(currentQuestionIndex<10){
                  correctAnswer = questionsAndAnswers4[index2][correctOptionIndex];
              }
              break;
          case 3:
              if(currentQuestionIndex<10){
                  correctAnswer = questionsAndAnswers12[index2][correctOptionIndex];
              }
              break;
          case 4:
              if(currentQuestionIndex<10){
                  correctAnswer = questionsAndAnswers13[index2][correctOptionIndex];
              }
              break;
          default:
              // 當輸入不是0、1或2時執行這裡的程式碼
              break;
          }
  int temp = Integer.parseInt(correctAnswer) - 1;
  // 設定按鈕顏色
  //fill(hover ? 200 : 255);
  fill(255);
  strokeWeight(4);
  
  if (isanswerCorrect & index == temp) {
    fill(0, 255, 0);
  }else if(isanswerWrong){
    fill(255, 0, 0);
  }
  
  // 繪製按鈕
  rect(x, y, w, h, 10);
  textAlign(CENTER,CENTER);
  // 繪製按鈕上的文字
  fill(0);
  textSize(16);
  text(label, x + w/2, y + h/2);
}

void drawQuestionAndOptions(String questionText, String[] options) {
  // 顯示問題跟分數
  //int ScoreX = width/2;
  //int ScoreY = 630;
  float textWidth = textWidth(questionText);
  float padding = 10;
  noTint();
  buffer.beginDraw();
  buffer.noTint();
  switch(question){
    case 1:
      buffer.background(255); // 清除緩衝區
      buffer.image(Theme1[currentQuestionIndex], 0, 0, width, height);
      break;
    case 2:
      buffer.background(255); // 清除緩衝區
      buffer.image(Theme2[currentQuestionIndex], 0, 0, width, height);
      break; 
    case 3:
      buffer.background(255); // 清除緩衝區
      buffer.image(Theme3[currentQuestionIndex], 0, 0, width, height);
      break;
    case 4:
      buffer.background(255); // 清除緩衝區
      buffer.image(Theme4[currentQuestionIndex], 0, 0, width, height);
      break;
  }
  buffer.fill(255);
  buffer.rectMode(CENTER);
  buffer.rect(width/2, height/4, textWidth * 2 + padding * 2, 20 + padding * 2 , 20);
  buffer.textFont(chineseFont);
  buffer.fill(0); // 設置文字顏色
  buffer.textAlign(CENTER, CENTER);
  buffer.textSize(32);
  buffer.text(questionText, width/2, height/4);//顯示問題
  buffer.fill(200,100);
  buffer.rect(width-160,  height/2, 160, 600, 20);
  buffer.fill(0);
  buffer.text("得分", width-180, height/2-40);//顯示分數
  buffer.fill(255,0,0);
  buffer.rect(width-100,height/2+10,30,Score*0.6);
  buffer.textFont(numberFont);
  buffer.text(Score,width-180,height/2+10);
  buffer.endDraw();
  image(buffer, 0, 0); // 一次性將緩衝區渲染到屏幕上
  
  if(currentQuestionIndex == 0 && !isone){
    startTimeSave = millis();
    isone = true;
  }
  startCountdown();
  
  
  // 顯示選項按鈕
  for (int i = 0; i < options.length; i++) {
    float buttonX = width/2 - w/2;
    float buttonY = height/4 + 80 + floor(i) * 60;
    drawButton(buttonX, buttonY, options[i], i);
  }
  switch(question) {
          case 1:
              if(currentQuestionIndex<10){
                  correctAnswer = questionsAndAnswers[currentQuestionIndex][correctOptionIndex];
              }
              break;
          case 2:
              if(currentQuestionIndex<10){
                  correctAnswer = questionsAndAnswers4[currentQuestionIndex][correctOptionIndex];
              }
              break;
          case 3:
              if(currentQuestionIndex<10){
                  correctAnswer = questionsAndAnswers12[currentQuestionIndex][correctOptionIndex];
              }
              break;
          case 4:
              if(currentQuestionIndex<10){
                  correctAnswer = questionsAndAnswers13[currentQuestionIndex][correctOptionIndex];
              }
              break;
          default:
              // 當輸入不是0、1或2時執行這裡的程式碼
              break;
          }
  temp = Integer.parseInt(correctAnswer) - 1;
  
  if (!sound_game.isPlaying()) {
    sound_game.rewind();
  }
  sound_game.play();
}

void drawButton(float x, float y, String label, int index) {
  // 檢查滑鼠是否懸停在按鈕上
  //boolean hover = mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
  String correctAnswer = questionsAndAnswers[currentQuestionIndex][correctOptionIndex];
  switch(question) {
          case 1:
              if(currentQuestionIndex<10){
                  correctAnswer = questionsAndAnswers[currentQuestionIndex][correctOptionIndex];
              }
              break;
          case 2:
              if(currentQuestionIndex<10){
                  correctAnswer = questionsAndAnswers4[currentQuestionIndex][correctOptionIndex];
              }
              break;
          case 3:
              if(currentQuestionIndex<10){
                  correctAnswer = questionsAndAnswers12[currentQuestionIndex][correctOptionIndex];
              }
              break;
          case 4:
              if(currentQuestionIndex<10){
                  correctAnswer = questionsAndAnswers13[currentQuestionIndex][correctOptionIndex];
              }
              break;
          default:
              // 當輸入不是0、1或2時執行這裡的程式碼
              break;
          }
  int temp = Integer.parseInt(correctAnswer) - 1;
  
  // 設定按鈕顏色
  //fill(hover ? 200 : 255);
  fill(255);
  strokeWeight(4);
  
  if (isanswerCorrect & index == temp) {
    fill(0, 255, 0);
  }else if(isanswerWrong){
    fill(255, 0, 0);
  }
  
  // 繪製按鈕
  rect(x, y, w, h, 10);
  
  // 繪製按鈕上的文字
  fill(0);
  textSize(16);
  text(label, x + w/2, y + h/2);
}

int selectedOptionIndex = -1; // 初始化選擇的選項為-1

//滑鼠移動
void custommousemove(){
    xval = arduino.analogRead(xPin);   //讀取X軸數值到xval變數
    yval = arduino.analogRead(yPin);   //讀取Y軸數值到yval變數
    zval = arduino.analogRead(zPin);   //讀取Z軸數值到zval變數
    yval = 1023-yval;
    //println("xval"+xval);
    //println("yval"+yval);
    //println("zval"+zval);
     
   if(xval > 800){
     cosmouseX += speed;
   }else if(xval < 200){
     cosmouseX -= speed;
   }
   if(yval > 800){
     cosmouseY -= speed;
   }else if(yval < 200){
     cosmouseY += speed;
   }
      
   int mouseXPosition = constrain(cosmouseX, 0, width-20);
   int mouseYPosition = constrain(cosmouseY, 0, height-30);
   image(mouseIcon, mouseXPosition, mouseYPosition,  20,  30);
   //println("mouseXPosition "+mouseXPosition);
   //println("mouseYPosition "+mouseYPosition);
}
//看是按了哪個按鈕
void startbuttonreleased(){
  for (int i = 0; i < 3; i++) {
        float buttonX = 540;
        float buttonY = 350 + floor(i) * 200;
    
        if (cosmouseX >= buttonX && cosmouseX <= buttonX + 600 && cosmouseY >= buttonY && cosmouseY <= buttonY + 130 && arduino.digitalRead(6) == Arduino.LOW) {
          switch(i) {
            case 0:
                //start
                delay(1000);
                isstart = false;
                isselect = true;
                sound_lobby.pause();
                break;
            case 1:
                // shop
                isstart = false;
                isshop = true;
                sound_lobby.pause();
                delay(1000);
                break;
            case 2:
                // quit
                System.exit(0); 
                break;
            default:
                // 當輸入不是0、1或2時執行這裡的程式碼
                break;
            }
            break;
      }
     }
}

void selectbuttonreleased(){
  for (int i = 0; i < 5; i++) {
        float buttonX = 0;
        float buttonY = 0;
        if(i%2 == 0){
          buttonX = 200;
        }else{
          buttonX = 900;
        }
        if(i/2 == 0){
          buttonY = 280;
        }else{
          buttonY = 530;
        }
    
        if (mouseX >= buttonX && mouseX <= buttonX + 600 && mouseY >= buttonY && mouseY <= buttonY + 130 && arduino.digitalRead(6) == Arduino.LOW) {
          switch(i) {
            case 0:
                isstart = false;
                isselect = false;
                question = 1;
                sound_lobby.pause();
                break;
            case 1:
                isstart = false;
                isselect = false;
                question = 2;
                sound_lobby.pause();
                break;
            case 2:
                isstart = false;
                isselect = false;
                question = 3;
                sound_lobby.pause();
                break;
            case 3:
                isstart = false;
                isselect = false;
                question = 4;
                sound_lobby.pause();
                break;
            default:
                break;
            }
            break;
        }
        if(i == 4){
          buttonX = 450;
          buttonY = 750;
          if(mouseX >= buttonX && mouseX <= buttonX + 750 && mouseY >= buttonY && mouseY <= buttonY + 130 && arduino.digitalRead(6) == Arduino.LOW){
            isstart = true;
            isselect = false;
            delay(1000);
          }   
        }
     }
}

void endbuttonreleased(){
  for (int i = 0; i < 3; i++) {
        String textToPrint = "";
        int rectX = 0;
        if(i == 0){
          textToPrint = "再試一次";
        }else if(i == 1){
          textToPrint = "離開";
        }else if(i == 2){
          textToPrint = "錯誤題目查詢";
        }
        int rectWidth = int(textWidth(textToPrint) + 80); // 矩形框的寬度為文字寬度加上80像素的邊距
        int rectHeight = 60; // 矩形框的高度
        if(i == 0){
          rectX = (width - rectWidth) / 2; // 矩形框左上角 x 座標，將其置中於畫面
        }else if(i == 1){
          rectX = (width - rectWidth) / 2 + 250; // 矩形框左上角 x 座標，將其置中於畫面
        }else if(i == 2){
          rectX = (width - rectWidth) / 2 + 500; // 矩形框左上角 x 座標，將其置中於畫面
        }
        int rectY = height - 60; // 矩形框左上角 y 座標，這裡是畫面高度減去矩形高度和底部邊距的值
        drawendbutton(rectX, rectY, rectWidth,textToPrint,i);
    
        if (cosmouseX >= rectX && cosmouseX <= rectX + rectWidth && cosmouseY >= rectY && cosmouseY <= rectY + rectHeight && arduino.digitalRead(6) == Arduino.LOW) {
          switch(i) {
            case 0:
                // 再試一次
                isstart = false;
                isselect = false;
                WrongQuestionSave = new ArrayList<>();
                rerestart();
                startTimeSave = millis(); // 重置倒計時的起始時間
                sound_result.pause();
                delay(1000);
                break;
            case 1:
                // 離開
                isstart = true;
                isselect = false;
                WrongQuestionSave = new ArrayList<>();
                question = 0;
                rerestart();
                sound_result.pause();
                delay(1000);
                break;
            case 2:
                // 錯誤題目查詢
                delay(1000);
                isstart = false;
                isselect = false;
                isCheckWrong = true;
                rerestart();
                sound_result.pause();
                break;
            default:
                // 當輸入不是0、1或2時執行這裡的程式碼
                break;
            }
            break;
      }
     }
    
}

void rerestart(){
    currentQuestionIndex = 0;
    //各種起始化狀態
    isanswerCorrect = false;
    isanswerWrong = false;
    isTimeOut = false;
    canPressButton =  true;
    isfirst = true;
    selectedOptionIndex = -1; // 重置選擇的選項 
    TotalTime = 0;
    Score = 0;
    numCorrect = 0;
    isWriteExp = false;
    isWriteCoin = false;
    expClicked = false;
    coinClicked = false;
    save("coinx2_original.png", coinx2); // 儲存原始圖片
    save("expx2_original.png", expx2); // 儲存原始圖片
    coinx2 = loadImage("coinx2_original.png"); // 恢復原始圖片
    expx2 = loadImage("expx2_original.png"); // 恢復原始圖片
    isone = false;
}

void checkAnswer(float x, float y) {
  // 檢查選擇的答案是否正確
  if (selectedOptionIndex == Integer.parseInt(correctAnswer) - 1) {
     Correct(x,y,selectedOptionIndex);
  }else{
     Wrong(x,y,selectedOptionIndex,temp);
  }
}

// 計時器函數
void timer(int milliseconds) {
  // 獲取目前的時間
  int startTime = millis();
  
  // 等待指定的時間
  while (millis() - startTime < milliseconds) {
    // 空循環
  }
  
  restart();
}

void restart(){
// 重新設置顏色為白色，這樣下一個循環將不會保留綠色
  fill(255);
  //各種起始化狀態
  isanswerCorrect = false;
  isanswerWrong = false;
  isTimeOut = false;
  canPressButton =  true;
  isfirst = true;
  //題目加1喔
  currentQuestionIndex++;
  selectedOptionIndex = -1; // 重置選擇的選項 
  TotalTime += elapsedTime;
  startTimeSave = millis(); // 重置倒計時的起始時間  
}

void TimeOut(){
    float buttonX = width/2 - w/2;
    float buttonY = height/4 + 80 + floor(temp) * 60;
    
    int[] array1 = {currentQuestionIndex,-1};
    WrongQuestionSave.add(array1);
    
    isanswerCorrect =  true;
    isTimeOut = true;
    drawButton(buttonX,buttonY,options[temp], temp); 
}

void startCountdown() {
  if(isfirst == false){
    startTimeSave = millis();
    isfirst = true;
  }
  elapsedTime = millis() - startTimeSave;
  int remainingTime = countdownDuration * 1000 - elapsedTime;
  int seconds = ceil(remainingTime / 1000.0);
  
  if (seconds >= 0) {
    textAlign(CENTER, CENTER);
    textFont(numberFont);
    textSize(64);
    fill(255, 0, 0);
    text(seconds, width/2, 100);
    textFont(chineseFont);
  } else {
    textAlign(CENTER, CENTER);
    textFont(chineseFont);
    TimeOut();
    textSize(64);
    fill(255, 0, 0);
    text("時間到!", width/2, 100);
  }
}
void Correct(float x, float y,int selectedOptionIndex){
    sound_correct.play();
    Score += 100;
    numCorrect += 1;
    // 如果答對了，顯示下一個問題  
    isanswerCorrect =  true;
    drawButton(x,y,options[selectedOptionIndex], selectedOptionIndex);
}

void Wrong(float x, float y,int selectedOptionIndex, int temp){
    sound_incorrect.play();
    int[] array1 = {currentQuestionIndex,selectedOptionIndex};
    WrongQuestionSave.add(array1);
    isanswerWrong = true;
    drawButton(x,y,options[selectedOptionIndex], selectedOptionIndex);
    float buttonY = height/4 + 80 + floor(temp) * 60;
    isanswerCorrect =  true;
    drawButton(x,buttonY,options[temp], temp);
}
//起始畫面
void loadIcons() {
  for (int i = 1; i <= maxLevel; i++) {
    levelIcons[i] = loadImage("level_" + i + ".png"); // 假設圖標檔名為 level_1.png, level_2.png, ...
  }
}

void drawstart(){
  background(0); 
  image(bg,0,0);  
  tint(150,255);   //tint(明度,透明度)
  textAlign(LEFT);  
  //title
  textSize(100);
  fill(255);
  stroke(0,0,255);
  strokeWeight(10);
  textFont(chineseFont, 100);
  text("SDGS",300,220);
  textFont(chineseFont,100);
  text("知識大學堂挑戰!",550,220);
  
  for (int i = 0; i < 3; i++) {
    float buttonX = 540;
    float buttonY = 350 + floor(i) * 200;
    drawstartbutton(buttonX, buttonY,i);
  }
  
  drawExperienceBar();
  
  if (!sound_lobby.isPlaying()) {
    sound_lobby.rewind();
  }
  sound_lobby.play();
    
}
void drawstartbutton(float x, float y, int index){
  mouseX = cosmouseX;
  mouseY = cosmouseY;
  boolean hover = mouseX >= x && mouseX <= x + 600 && mouseY >= y && mouseY <= y + 130;
  
  //這邊改顏色
  fill(hover ? 200 : 46,139,87);
  //start
  stroke(0);
  rect(x,y,600,130);  
  
  switch(index) {
    case 0:
        // 當輸入為0時執行這裡的程式碼
        textSize(128);
        fill(255);
        textFont(chineseFont, 80);
        text("開始", 760,450); 
        break;
    case 1:
        // 當輸入為1時執行這裡的程式碼
        textSize(128);
        fill(255);
        textFont(chineseFont, 80);
        text("商城", 760,650); 
        break;
    case 2:
        // 當輸入為2時執行這裡的程式碼
        textSize(128);
        fill(255);
        textFont(chineseFont, 80);
        text("離開", 760,840); 
        break;
    default:
        // 當輸入不是0、1或2時執行這裡的程式碼
        break;
  }
}

void drawExperienceBar() {
  float barWidth = width - 200; // 經驗條的寬度
  float barHeight = 40; // 經驗條的高度
  float barX = 100; // 經驗條的起始X坐標
  float barY = barHeight*2-10; // 經驗條的Y坐標
 //<>//
  // 繪製經驗條的背景
  fill(200);
  rect(barX, barY, barWidth, barHeight);
  
  // 計算當前經驗值占總經驗值的比例
  float expRatio = (float) totalExp / levelExp[maxLevel];
  //print("Exp",totalExp);
  // 計算當前經驗條的寬度
  float expWidth = expRatio * barWidth;
  
  // 繪製經驗條
  fill(0, 0, 255); // 藍色
  rect(barX, barY, expWidth, barHeight);
  
  // 在經驗條上顯示當前經驗值和總經驗值
  fill(0); // 黑色
  textAlign(CENTER);
  textSize(16);
  text(totalExp + "/" + levelExp[maxLevel], barX + expWidth / 2, barY + barHeight / 2 + 5);
  // 繪製等級圖標
  float iconSize = 50; // 圖標大小
  float iconSpacing = (barWidth - iconSize - 100) / (maxLevel - 1); // 圖標間距
  
  for (int i = 1; i <= maxLevel; i++) {
    float iconX = barX + 120 + iconSpacing * (i - 1);
    float iconY = barY - iconSize - 10; // 圖標的Y坐標
    
    image(levelIcons[i], iconX, iconY, iconSize, iconSize);
  }
}

//關卡選擇
void drawselect(){
  float buttonX = 0;
  float buttonY = 0;
    
  background(0); 
  image(bgselect,0,0);  
  tint(230,230);   //tint(明度,透明度)
  textAlign(LEFT); 
  //title
  textSize(100);
  fill(255);
  stroke(0,0,255);
  strokeWeight(10);
  textFont(chineseFont, 100);
  text("關卡選擇", 650,180); 
  
  for (int i = 0; i < 4; i++) {
    if(i%2 == 0){
      buttonX = 200;
    }else{
      buttonX = 900;
    }
    if(i/2 == 0){
      buttonY = 280;
    }else{
      buttonY = 530;
    }
    drawselectbutton(buttonX, buttonY,i);
  }
  buttonX = 450;
  buttonY = 750;
  //back
  drawselectbutton(buttonX, buttonY,4);
  if (!sound_lobby.isPlaying()) {
    sound_lobby.rewind();
  }
  sound_lobby.play();
}

void drawselectbutton(float x, float y, int index){
  mouseX = cosmouseX;
  mouseY = cosmouseY;
  boolean hover = mouseX >= x && mouseX <= x + 600 && mouseY >= y && mouseY <= y + 130;
  if(index == 4){
    hover = mouseX >= x && mouseX <= x + 750 && mouseY >= y && mouseY <= y + 130;
  }
  
  //這邊改顏色
  fill(hover ? 200 : 46,139,87);
  
  if(index == 4){
    //返回
    stroke(0);
    rect(x,y,750,130);
    textSize(128);
    fill(255); 
    textFont(chineseFont, 80);
    text("返回大廳", 660,850); 
  }else{
    stroke(0);
    rect(x,y,600,130); 
  }
  switch(index) {
    case 0:
        // 當輸入為0時執行這裡的程式碼
        textSize(128);
        fill(255); 
        textFont(chineseFont, 80);
        text("SDG2", 380,380); 
        break;
    case 1:
        // 當輸入為1時執行這裡的程式碼
        textSize(128);
        fill(255); 
        textFont(chineseFont, 80);
        text("SDG4", 1080,380);
        break;
    case 2:
        // 當輸入為2時執行這裡的程式碼
        textSize(128);
        fill(255); 
        textFont(chineseFont, 80);
        text("SDG12", 380,630); 
        break;
     case 3:
        // 當輸入為3時執行這裡的程式碼
        textSize(128);
        fill(255); 
        textFont(chineseFont, 80);
        text("SDG13", 1080,630); 
        break;
    default:
        // 當輸入不是0、1或2時執行這裡的程式碼
        break;
  }
}
//結算畫面
void drawsettlement() {
  noTint();
  background(255);
  image(sun,0,0);
  //drawS();
  
  printGain();

  
  image(coin, 1050, 250, coin.width/2, coin.height/2);
  image(exp, 1050, 450, exp.width*2, exp.height*2);
  
  printRectangle();
  
  printRectangle2();
  
  rectangle_bottom_line();
  
  for (int i = 0; i < 3; i++) {
    String textToPrint = "";
    int rectX = 0;
    if(i == 0){
      textToPrint = "再試一次";
    }else if(i == 1){
      textToPrint = "離開";
    }else if(i == 2){
      textToPrint = "錯誤題目查詢";
    }
    textFont(chineseFont);    
    int rectWidth = int(textWidth(textToPrint) + 80); // 矩形框的寬度為文字寬度加上80像素的邊距
    if(i == 0){
      rectX = (width - rectWidth) / 2; // 矩形框左上角 x 座標，將其置中於畫面
    }else if(i == 1){
      rectX = (width - rectWidth) / 2 + 250; // 矩形框左上角 x 座標，將其置中於畫面
    }else if(i == 2){
      rectX = (width - rectWidth) / 2 + 500; // 矩形框左上角 x 座標，將其置中於畫面
    }
    int rectY = height - 60; // 矩形框左上角 y 座標，這裡是畫面高度減去矩形高度和底部邊距的值
    drawendbutton(rectX, rectY, rectWidth,textToPrint,i);
  }
  printTime();
  
  displayCoins(numCorrect);
  displayExps(numCorrect);
  
  if (!sound_result.isPlaying()) {
    sound_result.rewind();
  }
  sound_result.play();
}
void drawS() {
  float centerX = width / 2;
  float centerY = height / 2;
  float size = 1000; // 调整S形的大小
  noFill();
  beginShape();
  vertex(centerX + 600 - size / 2, centerY - size / 2); // 左上角
  bezierVertex(centerX - 300 - size / 2, centerY - size / 4, centerX + size / 2, centerY - size / 4, centerX + size / 2 -400, centerY); // 左上到右上
  bezierVertex(centerX  + size / 2 -200, centerY + size / 4, centerX - size / 2, centerY + size / 4 *2, centerX - size / 2 , centerY + size / 2); // 右上到左下
  bezierVertex(centerX - size / 2 , centerY + size / 4 * 2, centerX + size / 2, centerY + size / 4 * 3, centerX + size / 2 -200, centerY + size / 2); // 左下到右下
  vertex(centerX + size / 2 - 200, centerY + size / 2); // 右下角
  endShape();
}

void printRectangle(){
  stroke(0); // 設置邊框顏色為黑色
  strokeWeight(5); // 設置邊框線粗細為2像素
  fill(255, 0, 0); // 設置填充顏色為紅色
  value1 = HighScore.get(question-1);
  rect(170, height-value1*0.6 - 200, 200, value1*0.6); // 在x座標100的位置處繪製一個寬度為50，高度為value1的長條，y座標上提高了50像素
  fill(0); // 設置文字顏色為黑色
  textAlign(CENTER); // 文字居中對齊
  textFont(numberFont);
  text(value1, 170 + 200/2, height - 130); // 在矩形底部居中位置顯示 "History Score"
  textFont(chineseFont);
  if(!isWriteScore){
    for(int i = 0; i < 4 ;i++){
      if(question == (i+1)){
         int currentHighscore = max(value1,Score);
         HighScore.set(i, currentHighscore);
      }
    }
    
    
    Properties properties = new Properties();
    properties.setProperty("Theme1", Integer.toString(HighScore.get(0)));
    properties.setProperty("Theme2", Integer.toString(HighScore.get(1)));
    properties.setProperty("Theme3", Integer.toString(HighScore.get(2)));
    properties.setProperty("Theme4", Integer.toString(HighScore.get(3)));
    
    
    // 將變量名稱和值寫入檔案
    try (OutputStream outputStream = new FileOutputStream(filePath2)) {
      // 使用 properties 的 store() 方法將變量名稱和值寫入到 outputStream 中，並附上註釋 "Variables"
      properties.store(outputStream, "Variables");
      System.out.println("成功將變量名稱和值寫入檔案。");
      isWriteScore = true;
    } catch (IOException e) {
      // 如果發生 IOException，則捕獲異常並輸出錯誤消息
      System.out.println("寫入檔案時發生錯誤：" + e.getMessage());
    }
  }
}

void printRectangle2(){
  stroke(0); // 設置邊框顏色為黑色
  strokeWeight(5); // 設置邊框線粗細為2像素
  fill(0, 0, 255); // 設置填充顏色為藍色
  value2 = Score;
  rect(420, height-value2*0.6 - 200, 200, value2*0.6); // 在x座標250的位置處繪製一個寬度為50，高度為value2的長條，y座標上提高了50像素
  fill(0); // 設置文字顏色為黑色
  textAlign(CENTER); // 文字居中對齊
  textFont(numberFont);
  text(value2, 420 + 200/2, height - 130); // 在矩形底部居中位置顯示 "New Score"
  textFont(chineseFont);
}

void rectangle_bottom_line(){
  // 繪製底部線條
  stroke(0); // 設置顏色為黑色
  strokeWeight(10); // 設置線條粗細為10像素
  line(120, height - 200, 700, height - 200); // 在底部繪製一條線，x座標從120到700，y座標是畫面高度減去200像素
}
void printGain() {
  String textToPrint = "收獲";
  fill(0); // 設置文本顏色為黑色
  textSize(60); // 設置文本大小
  textFont(createFont("細明體_HKSCS", 60));     // 字體為 Lucida Fax Italic
  text(textToPrint,1300,170); // 在右上角印出文本
  stroke(0); // 設置顏色為黑色
  strokeWeight(5); // 設置線條粗細為10像素
  line(1200,200,1400,200); // 在底部繪製一條線，x座標從350到600，y座標是畫面高度減去200像素
}

void printTime(){
  String timeString = Float.toString(TotalTime/1000.0); // 假設這是你的時間字串
  fill(0); // 設置文字顏色為黑色
  textFont(chineseFont);
  textSize(50); // 設置文字大小為 50
  text(" 時間 :",100, 80); // 在 (10, 30) 的位置印出 "時間: "
  textFont(numberFont);
  textSize(50); // 設置文字大小為 50
  text(timeString, 280, 70); // 在 "時間: " 的右邊印出時間字串
  textFont(chineseFont);
}

void drawendbutton(float x, float y, int w, String text, int index){
  mouseX = cosmouseX;
  mouseY = cosmouseY;
  int rectHeight = 60; // 矩形框的高度
  boolean hover = mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + rectHeight;
  
  //這邊改顏色
  fill(hover ? 200 : 255);
  stroke(0);
  strokeWeight(5);
  rect(x,y-20,w,rectHeight);
  textFont(chineseFont);
  
  switch(index) {
    case 0:
        // 當輸入為0時執行這裡的程式碼
        // 繪製文本
        fill(0); // 文本顏色為黑色
        strokeWeight(5);
        textAlign(CENTER, BOTTOM); // 文本對齊方式
        textSize(30); // 文本大小
        text(text, x + w / 2, y + 25); // 繪製文本，置中於矩形框內
        break;
    case 1:
        // 當輸入為1時執行這裡的程式碼
        // 繪製文本
        fill(0); // 文本顏色為黑色
        strokeWeight(5);
        textAlign(CENTER, BOTTOM); // 文本對齊方式
        textSize(30); // 文本大小
        text(text, x + w / 2, y + 25); // 繪製文本，置中於矩形框內
        break;
    case 2:
        // 當輸入為2時執行這裡的程式碼
        // 繪製文本
        fill(0); // 文本顏色為黑色
        strokeWeight(5);
        textAlign(CENTER, BOTTOM); // 文本對齊方式
        textSize(30); // 文本大小
        text(text, x + w / 2, y + 25); // 繪製文本，置中於矩形框內
        break;
    default:
        // 當輸入不是0、1或2時執行這裡的程式碼
        break;
  }
}

void displayCoins(int numCorrect) {
  int coinsToShow = min(numCorrect, totalQuestions);
  int coins = coinsToShow * (maxCoins / totalQuestions);
  if(coinClicked){
    coins = coinsToShow * (maxCoins / totalQuestions) * 2;
  }
  variableName = "coin";
  if(!isWriteCoin){
    totalCoin += coins;
    try (PrintWriter writer = new PrintWriter(filePath)) {
        writer.println(variableName + "=" + totalCoin);
        System.out.println("已成功將變數名稱和值寫入檔案。");
        isWriteCoin = true;
    } catch (IOException e) {
        System.out.println("寫入檔案時發生錯誤：" + e.getMessage());
    }
  }
  
  // 顯示金幣數量
  fill(0); // 黃色文字顏色
  textSize(40);
  textAlign(CENTER, CENTER);
  textFont(numberFont);
  text(coins, 1300, 330);
  textFont(chineseFont);
}

void displayExps(int numCorrect) {
  int expsToShow = min(numCorrect, totalQuestions);
  int exps = expsToShow * (maxExps / totalQuestions);
  if(expClicked){
    exps = expsToShow * (maxExps / totalQuestions) * 2;
  }
  variableName = "exp";
  if(!isWriteExp){
    totalExp += exps;
    try (PrintWriter writer = new PrintWriter(new BufferedWriter(new FileWriter(filePath, true)))) {//追加模式
        writer.println(variableName + "=" + totalExp);
        System.out.println("已成功將變數名稱和值寫入檔案。");
        isWriteExp = true;
    } catch (IOException e) {
        System.out.println("寫入檔案時發生錯誤：" + e.getMessage());
    }
  }
  ExptoCoin();
  if(!isWriteBool){
    try (PrintWriter writer = new PrintWriter(filePath3)) {
        for (Boolean value : booleanList) {
            writer.println(value); // 寫入每個布爾值到文件中的一行
        }
        System.out.println("布爾值已成功寫入到文件。");
        isWriteBool = true;
    } catch (IOException e) {
        System.out.println("寫入文件時發生錯誤：" + e.getMessage());
    }
  }
  
  // 顯示經驗數量
  fill(0); // 藍色文字顏色
  textSize(40);
  textAlign(CENTER, CENTER);
  textFont(numberFont);
  text(exps, 1300, 520);
  textFont(chineseFont);
}

void ExptoCoin(){
    int i = totalExp/100;

        // 使用 switch case 每 100 為間隔處理 0 到 1000 的情況
        switch (totalExp / 100 * 100) {
            case 0:
                break;
            case 100:
                if(!booleanList.get(i-1)){
                  totalCoin += i;
                  booleanList.set(i-1,true);
                }
                break;
            case 200:
                if(!booleanList.get(i-1)){
                  totalCoin += i;
                  booleanList.set(i-1,true);
                }
                break;
            case 300:
                if(!booleanList.get(i-1)){
                  totalCoin += i;
                  booleanList.set(i-1,true);
                }
                break;
            case 400:
                if(!booleanList.get(i-1)){
                  totalCoin += i;
                  booleanList.set(i-1,true);
                }
                break;
            case 500:
                if(!booleanList.get(i-1)){
                  totalCoin += i;
                  booleanList.set(i-1,true);
                }
                break;
            case 600:
                if(!booleanList.get(i-1)){
                  totalCoin += i;
                  booleanList.set(i-1,true);
                }
                break;
            case 700:
                if(!booleanList.get(i-1)){
                  totalCoin += i;
                  booleanList.set(i-1,true);
                }
                break;
            case 800:
                if(!booleanList.get(i-1)){
                  totalCoin += i;
                  booleanList.set(i-1,true);
                }
                break;
            case 900:
                if(!booleanList.get(i-1)){
                  totalCoin += i;
                  booleanList.set(i-1,true);
                }
                break;
            default:
                System.out.println("超出範圍");
        }
}

//商店
void drawshop(){
  noTint(); 
  background(0); // 繪製背景
  //image(store,0,0,store.width / 1.2,store.height / 2);
  image(scaledImg,0,0);
  
  printback(); // 呼叫 printback() 函式繪製矩形框和文字
  printstore();
  printcontent();
  
  // 根據點擊狀態決定要顯示的圖片
  if (coinClicked) {
    image(coinx2, width / 2 - 250 , height / 2 - 50, coinx2.width / 4, coinx2.height / 4);
  } else {
    image(coinx2, width / 2 - 250 , height / 2 - 50, coinx2.width / 4, coinx2.height / 4);
  }
  if (expClicked) {
    image(expx2, width / 2 + 50 , height / 2 - 80, expx2.width / 2.5, expx2.height / 2.5);
  } else {
    image(expx2, width / 2 + 50 , height / 2 - 80, expx2.width / 2.5, expx2.height / 2.5);
  }

  displaymoney();
  displayexplain();
  
  if (!player.isPlaying()) {
      player.rewind();
    }
  player.play();
  
}

void printback() {
  String textToPrint = "離開"; // 要顯示的中文文字
  textFont(myFont); // 使用TTF字型
  int rectWidth = int(textWidth(textToPrint) + 80); // 計算矩形框的寬度，文字寬度加上 80 像素的邊距
  int rectHeight = int(textWidth(textToPrint) + 20); // 設定矩形框的高度為 60 像素
  int rectX = 20; // 設定矩形框左上角 x 座標為 20 像素，靠左
  int rectY = 20; // 設定矩形框左上角 y 座標為 20 像素，靠上

  // 繪製矩形框
  fill(200,100); // 設定填充色為灰色
  strokeWeight(5); // 設定線條寬度為 5 像素
  rect(rectX, rectY, rectWidth, rectHeight, 20); // 繪製矩形框

  // 繪製文字
  fill(0); // 設定文字顏色為黑色
  textAlign(CENTER,BOTTOM); // 設定文字對齊方式為置中下對齊
  textSize(35); // 設定文字大小為 30
  text(textToPrint, rectX + rectWidth / 2, rectY + rectHeight / 2 + 20); // 繪製文字，置中於矩形框內
}

void printstore() {
  int boxWidth = width - 1200; // 設定矩形框的寬度為畫布寬度減去兩側邊距
  int boxHeight = 200; // 設定矩形框的高度為 200 像素
  int cornerRadius = 20; // 設定圓角的半徑為 20 像素
  int boxX = width / 2 - 200; // 設定矩形框左上角 x 座標
  int boxY = height / 2 - 400; // 設定矩形框左上角 y 座標
  
  // 繪製商城矩形框
  fill(200,100); 
  strokeWeight(2); // 設定線條寬度為 2 像素
  rect(boxX, boxY, boxWidth, boxHeight, cornerRadius); // 繪製圓角矩形框

// 在矩形框內印出 "商店" 這個字，使用粗體字型
  fill(0); // 設定文字顏色為黑色
  textAlign(CENTER, CENTER); // 設定文字對齊方式為置中
  textSize(70); // 設定文字大小為 70
  textFont(myFont,70); // 使用TTF字型 
  text("商店", boxX + boxWidth / 2, boxY + boxHeight / 2); // 繪製文字，置中於矩形框內
}

void printcontent(){
  int cornerRadius = 20; // 設定圓角的半徑為 20 像素
  
  noStroke(); // 不繪製邊框
  fill(200, 100); // 設置填充色為半透明灰色
  rect(width / 2 - 312,height / 2 - 120,705,400,cornerRadius);
}

void shopmousePressed() {
  // 檢查滑鼠點擊位置是否在圖片範圍內
  if (cosmouseX > width / 2 - 250 && cosmouseX < width / 2 - 250 + coinx2.width / 4 &&
      cosmouseY > height / 2 - 50 && cosmouseY < height / 2 - 50 + coinx2.height / 4 && arduino.digitalRead(6) == Arduino.LOW) {
    // 如果已點擊過圖片，則恢復原始圖片並加回金幣量
    
    if (coinClicked) {
      coinx2 = loadImage("coinx2.png"); // 恢復原始圖片
      totalCoin += requiredCoins; // 加回扣除的金幣量
      coinClicked = false; // 將點擊狀態設置為 false
      save("coinx2_original.png", coinx2); // 儲存原始圖片
      delay(1000);
    } else {
      // 檢查金幣量是否足夠
      if (totalCoin >= requiredCoins) {
        coinx2.filter(GRAY); // 將coinx2圖片轉換為灰階
        save("coinx2_gray.png", coinx2); // 儲存修改後的圖片
        totalCoin -= requiredCoins; // 扣除購買所需的金幣量
        coinClicked = true; // 將點擊狀態設置為 true
        delay(1000);
      }
    }
  }
  
  if (cosmouseX > width / 2 + 50 && cosmouseX < width / 2 + 50 + expx2.width / 2.5 &&
      cosmouseY > height / 2 - 80 && cosmouseY < height / 2 - 80 + expx2.height / 2.5 && arduino.digitalRead(6) == Arduino.LOW) {
    // 如果已點擊過圖片，則恢復原始圖片並加回金幣量
    if (expClicked) {
      expx2 = loadImage("expx2.png"); // 恢復原始圖片
      totalCoin += requiredCoins; // 加回扣除的金幣量
      expClicked = false; // 將點擊狀態設置為 false
      save("expx2_original.png", expx2); // 儲存原始圖片
      delay(1000);
    } else {
      // 檢查金幣量是否足夠
      if (totalCoin >= requiredCoins) {
        expx2.filter(GRAY); // 將expx2圖片轉換為灰階
        save("expx2_gray.png", expx2); // 儲存修改後的圖片
        totalCoin -= requiredCoins; // 扣除購買所需的金幣量
        expClicked = true; // 將點擊狀態設置為 true
        delay(1000);
      }
    }
  }
  
  //按離開鍵停止音樂
  String textToPrint = "離開"; // 要顯示的中文文字
  int rectWidth = int(textWidth(textToPrint) + 80); // 計算矩形框的寬度，文字寬度加上 80 像素的邊距
  int rectHeight = int(textWidth(textToPrint) + 20); // 設定矩形框的高度為 60 像素
  // 檢查是否點擊了 "離開" 文字，並停止音樂
  if (cosmouseX > 20 && cosmouseX < 20 + rectWidth && cosmouseY > 20 && cosmouseY < 20 + rectHeight && arduino.digitalRead(6) == Arduino.LOW) {
    player.pause(); // 停止音樂
    //minim.stop(); // 停止 Minim
    isshop = false;
    isstart = true;
    delay(1000);
}
}

void save(String filename, PImage img) {
  // 儲存圖片
  img.save(filename);
}

void displaymoney(){
  noFill();
  fill(200,100);
  rect(10,150,420,100,20);
  
   // 顯示現有金幣量
  fill(0);
  textSize(32);
  text("現有金幣量：", 120, 200);
  textFont(numberFont);
  text(totalCoin, 270, 200);
  textFont(chineseFont);
  image(coin,310,125,coin.width / 2.3,coin.height / 2.3);
}

void displayexplain(){
  // 顯示道具說明
  fill(0);
  textFont(myFont,48); // 使用TTF字型
  text("金幣量2倍", 700, 680);
  text("經驗值2倍", 1060, 680);
}
