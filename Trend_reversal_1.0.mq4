//+------------------------------------------------------------------+
//|                                               trend reversal.mq4 |
//|                              Copyright � 2013, drivermql@mail.ru |
//|                                        http://stavmany.ru/forex/ |
//+------------------------------------------------------------------+

#property copyright "Copyright � 2013, drivermql@mail.ru"
#property link      "http://stavmany.ru/forex/"

extern string    name           = "Trend Reversal 1.0";
extern string    txxt           = "��������� ��������";
extern int       hourstart      = 0;
extern int       hourend        = 23;
extern double    lots           = 0.01;
extern int       takeprofit     = 150;
extern int       stoploss       = 45;
extern int       slippage       = 3;
extern int       magic          = 231013;
//*****************************************
extern string    twex           = "��������� Visual MACD";
extern int       ma_1           = 28;
extern int       ma_2           = 144;
extern int       method         = 3;
extern int       price          = 0;
extern int       signal         = 5;
extern int       s_method       = 0;
extern int       signal2        = 31;
extern int       s_method2      = 0;
extern string    names          = "��������� ���-�� SDA";
extern int    Len             = 150;
extern int    HistoryBars     = 500;
extern int    TF1             = 1;
extern int    TF2             = 0;
extern bool   ModeHL          = TRUE;
extern string i1 = "===��������� �������===";
extern bool   ModeOnline      = TRUE;
extern bool   ModeinFile      = FALSE;
extern bool   ModeHistory     = FALSE;
extern string urovenindicatora = "������� ���-�� ��� �������� ������";   
extern double    uroven       = 15.0;

//*****************************************
extern string     xxt           = "���/����. ��������-c���� �� ParabolicSAR";
extern bool      trailingstop   = true;
extern string    psar           = "��������� ParabolicSar (����� ������ ��� ���������)";
extern double    Step           = 0.01;
extern double    Maximum        = 0.5;
extern string    pasr           = "�� ����� ����� ������� - �� 0 ��...";
extern int       tochka         = 4;

//**************���������� ����, ��� ��....
double sl, tp, sar,pos,reversallow,reversalhight,reversallowniz,reversalhightverkh,reversalsred,sdaorange,sdablue,vismacdteal,vismacdbroun;
int ticket;
//**************************************
int init()
  
  //��������������     ���������, ������� ������ ����� �������   �����������������������������
  {
if (Digits == 5 || Digits == 3)
   takeprofit   *=10;
   stoploss     *=10;
   slippage     *=10;

   return(0);
  }
int deinit()
  {
   return(0);
  }
int start()
  {
if (Volume[0]>1) return (0); // ��� ������ �� �������� ������
     {
if (Hour()<hourstart || Hour()>hourend) return(0);  // ������ ������ ��������
         {
 if (trailingstop == true)   trailing(); //����������� �������� ���� ��� ���
   
      // �������� ������ ��  #Trend_reversal_ind
      reversallow        = iCustom(Symbol(),0,"#Trend_reversal_ind",4,1);      
      reversalhight      = iCustom(Symbol(),0,"#Trend_reversal_ind",2,1); 
      reversallowniz     = iCustom(Symbol(),0,"#Trend_reversal_ind",5,1);   
      reversalhightverkh = iCustom(Symbol(),0,"#Trend_reversal_ind",1,1);  
      reversalsred       = iCustom(Symbol(),0,"#Trend_reversal_ind",3,1); 
      
      // �������� ������ ��  ViSUAL MACD
      vismacdteal  = iCustom (Symbol(),0,"Visual MACD",ma_1,ma_2,method,price,signal,s_method,signal2,s_method2,3,1);
      vismacdbroun = iCustom (Symbol(),0,"Visual MACD",ma_1,ma_2,method,price,signal,s_method,signal2,s_method2,2,1);
      
    //+----------------��������� ������ �� ���������� SDA ---------------------------------------------+  
    
    sdaorange = iCustom (Symbol(),0,"SDA v 3.2",1,1);
    sdablue   = iCustom (Symbol(),0,"SDA v 3.2",0,1);
       
       // �������� ������ �� ������������
       sar = iSAR (Symbol(),0,Step,Maximum,tochka);

      //������������� ������� ������� ��������������������������������������
  
  if ( CountSell() == 0 && CountBuy() ==0 && Close[1] > reversalhight &&   sdaorange > uroven && vismacdbroun  < vismacdteal)  
   
   {
     sl = NormalizeDouble(Bid + stoploss * Point,Digits); // ������ ���� ���� � ��������� ����
     tp = NormalizeDouble(Bid - takeprofit *Point,Digits); // �� �� � ������
     sar = NormalizeDouble (sar,Digits);
     reversalhightverkh = NormalizeDouble (reversalhightverkh,Digits);
     reversallow        = NormalizeDouble (reversallow,Digits);
     reversalsred       = NormalizeDouble  (reversalsred,Digits);
     
     ticket = OrderSend (Symbol(),OP_SELL,lots,Bid,slippage,0,0,name,magic,0,Red);
     if (ticket>0)
     {
       if (OrderSelect (ticket,SELECT_BY_TICKET,MODE_TRADES) == true) // �������� ����� ��� �����������
           OrderModify (ticket,OrderOpenPrice(),sl,reversalsred,0); // ������������ �� � �� ��� ��� ������
           
           }
        }
 //�������������������    ������� ��� �������   �������������������������������
  
    if (CountBuy() ==0 && CountSell() ==0  && Close[1] < reversallow && sdablue > uroven && vismacdbroun  > vismacdteal) 
   {
     sl = NormalizeDouble(Ask - stoploss * Point,Digits); // ������ ���� ���� � ��������� ����
     tp = NormalizeDouble(Ask + takeprofit *Point,Digits); // �� �� � ������
     sar = NormalizeDouble (sar,Digits);
     reversallowniz = NormalizeDouble (reversallowniz,Digits);
     reversalhight  = NormalizeDouble (reversalhight,Digits);
     reversalsred   = NormalizeDouble  (reversalsred,Digits);
     
     
     ticket = OrderSend (Symbol(),OP_BUY,lots,Ask,slippage,0,0,name,magic,0,Green);
     if (ticket>0)
     {
       if (OrderSelect (ticket,SELECT_BY_TICKET,MODE_TRADES) == true) // �������� ����� ��� �����������
           OrderModify (ticket,OrderOpenPrice(),sl,reversalsred,0); // ������������ �� � �� ��� ��� ������
            
        }
      }
    }
  }
   return(0);
}

 //***************������� �������� ����� �� ����������*********************
void trailing ()
{
  for (int i=0; i < OrdersTotal();i++)
   {
     if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
       {    
         if (OrderSymbol()==Symbol()&&OrderMagicNumber()==magic && OrderProfit() >0)
          {
            sl = NormalizeDouble (sar,Digits);
            reversalsred       = NormalizeDouble  (reversalsred,Digits);
            if (OrderStopLoss() != sl)
            OrderModify (OrderTicket(),OrderOpenPrice(), sl,reversalsred,0);
            }
          }
        }
      }     
//�����������������   ������������� ������ ��� �����������������������
int CountBuy ()
{
   int count = 0;
   for (int trade = OrdersTotal ()-1;trade>=0; trade--)
   {
     OrderSelect (trade, SELECT_BY_POS, MODE_TRADES);
     if (OrderSymbol ()==Symbol () && OrderMagicNumber ()==magic)
      {
        if (OrderType ()==OP_BUY)
        count++;
      }
    }
     return (count);
}

 //��������������   ������� ������ ����   ��������������������� 

int CountSell ()
{
   int count = 0;
   for (int trade = OrdersTotal ()-1;trade>=0; trade--)
   {
     OrderSelect (trade, SELECT_BY_POS, MODE_TRADES);
     if (OrderSymbol ()==Symbol () && OrderMagicNumber ()==magic)
      {
        if (OrderType ()==OP_SELL)
        count++;
      }
    }
    
    return (count);
 }