//+------------------------------------------------------------------+
//|                             ������ ��������� ��� �����������.mq4 |
//|                              Copyright � 2013, drivermql@mail.ru |
//|                                        http://stavmany.ru/forex/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, drivermql@mail.ru"
#property link      "hhttp://stavmany.ru/forex/"

extern string tt           ="�������������� � ����������� ������ �� �����!";
extern string txt          ="��������� ��������";
extern int    magic        = 30000;  
extern string comment      = "Gold Digger 1.0";
extern double InpLots      = 0.01; 
extern int    InpTakeProfit= 200;  
extern int    InpStopLoss  = 180;  



string b="��� �����";
int enter=0; // 0 - ����� ������ � �������, 1 - ����� ������� � �������

extern string b1="��������� Bollinger Bands";
extern int bolinger_per=140;
extern int bolinger_deviation_yellow=2;


 string xt="�������� BB";
 int yellow_blue_enter=2; // �������� ��� ������ �������� ���������� ����� ������ � ����� �����

extern string xtx="��������� RSI";
extern int RSIFilter=0; //�������� ������ �� RSI
extern int rsi_period=8;
extern int rsi_ur=70; // ������������� ����������� ������ ������� 100-80.

extern string txx="��������� Stohastic";
extern int StohasticFilter=1; // �������� ������ �� Stohastic-�
extern int stohastic_period=20;
extern int stohastic_ur=95; // ������������� ����������� ������ ������� 100-80.

//�������� �� ��������� �������
string �x="�������� ����� �������";
int close_type=2; // 0 - ��������� �� ������� �����, 1 - ������� ����� ������ � �������, 2 - ����� ������� � ������� , 3 - ��������� �� yellow_line, 4 - ��������� �� blue_line, 5 - ��������� �� red_line.

//����� ��� ����� �� �����, ��� ����� = 0;
string sf="��� ����� �� �����";
int shift=0;

int onebuy=1;

int okbuy,oksell;
int start()
  {

   double STP = InpTakeProfit;
   double TKP = InpStopLoss;
   if(Digits==5 || Digits==3)
     {
      STP = STP*10;
      TKP = TKP*10;
     }  
 int bolinger_deviation_blue=bolinger_deviation_yellow+(bolinger_deviation_yellow/bolinger_deviation_yellow);
 int bolinger_deviation_red=bolinger_deviation_yellow*2;     
  
//---- ������� ������ �����������
double bb_yellow_line_up=iBands(NULL,0,bolinger_per,bolinger_deviation_yellow,0,PRICE_CLOSE,MODE_UPPER,shift);
double bb_yellow_line_dw=iBands(NULL,0,bolinger_per,bolinger_deviation_yellow,0,PRICE_CLOSE,MODE_LOWER,shift);

double bb_blue_line_up=iBands(NULL,0,bolinger_per,bolinger_deviation_blue,0,PRICE_CLOSE,MODE_UPPER,shift);
double bb_blue_line_dw=iBands(NULL,0,bolinger_per,bolinger_deviation_blue,0,PRICE_CLOSE,MODE_LOWER,shift);

double bb_red_line_up=iBands(NULL,0,bolinger_per,bolinger_deviation_red,0,PRICE_CLOSE,MODE_UPPER,shift);
double bb_red_line_dw=iBands(NULL,0,bolinger_per,bolinger_deviation_red,0,PRICE_CLOSE,MODE_LOWER,shift);

double ma_line=iMA(NULL,0,bolinger_per,0,MODE_SMA,PRICE_CLOSE,shift+1);

if(RSIFilter) double rsi=iRSI(NULL,0,rsi_period,PRICE_CLOSE,shift);

if(StohasticFilter) double stohastic=iStochastic(NULL,0,stohastic_period,3,3,MODE_SMA,0,MODE_MAIN,shift);



//---- ���������� ������� �������� �������� ���������� ����� ������ � ������ ������� �����
double enterpriceBuy,enterpriceSell, priceclosebuy,proceclosesell; 

if(enter==0){//���� ����� ������ � �������
               enterpriceBuy =  bb_yellow_line_up+((bb_blue_line_up-bb_yellow_line_up)/2);
               enterpriceSell = bb_yellow_line_dw-((bb_yellow_line_dw-bb_blue_line_dw)/2);}

if(enter==1){//���� ����� ������� � �������
               enterpriceBuy =  bb_blue_line_up+((bb_red_line_up-bb_blue_line_up)/2);
               enterpriceSell = bb_blue_line_dw-((bb_blue_line_dw-bb_red_line_dw)/2);}
               
if(enter==2){//���� �� ������ �����
               enterpriceBuy =  bb_yellow_line_up;
               enterpriceSell = bb_yellow_line_dw;}
                              
if(enter==3){//���� �� ������� �����
               enterpriceBuy =  bb_blue_line_up;
               enterpriceSell = bb_blue_line_up;}
               
if(enter==4){//���� �� ������� �����
               enterpriceBuy =  bb_red_line_up;
               enterpriceSell = bb_red_line_dw;}
               
                              
   //���������� ���� ��� �������� ����� �������
   if((close_type==1 && enter==0) || (enter==1 && close_type==2) ){ //������ �������� ����� ������ � �����
   priceclosebuy=enterpriceSell;
   proceclosesell=enterpriceBuy;
   }               
   else{
   priceclosebuy= bb_blue_line_dw-((bb_blue_line_dw-bb_red_line_dw)/2);
   proceclosesell=bb_blue_line_up+((bb_red_line_up-bb_blue_line_up)/2);
   }
            
if(onebuy)
{

if(Bid>=enterpriceBuy   && !ChPos(1) && RSIFilter==0  && StohasticFilter==0){OpenOrderOnMarket(1,TKP,STP);}
if(Ask<=enterpriceSell  && !ChPos(0) && RSIFilter==0  && StohasticFilter==0){OpenOrderOnMarket(0,TKP,STP);}

if(Bid>=enterpriceBuy   && !ChPos(1) && (RSIFilter==1 && rsi>=rsi_ur) && StohasticFilter==0)       {OpenOrderOnMarket(1,TKP,STP);}
if(Ask<=enterpriceSell  && !ChPos(0) && (RSIFilter==1 && rsi<=(100-rsi_ur) ) && StohasticFilter==0){OpenOrderOnMarket(0,TKP,STP);}

if(Bid>=enterpriceBuy   && !ChPos(1) && RSIFilter==0  && ( StohasticFilter==1 && stohastic>stohastic_ur))      {OpenOrderOnMarket(1,TKP,STP);}
if(Ask<=enterpriceSell  && !ChPos(0) && RSIFilter==0  && ( StohasticFilter==1 && stohastic<(100-stohastic_ur))){OpenOrderOnMarket(0,TKP,STP);}

if(Bid>=enterpriceBuy   && !ChPos(1) && (RSIFilter==1 && rsi>=rsi_ur) && (StohasticFilter==1 && stohastic>stohastic_ur) )              {OpenOrderOnMarket(1,TKP,STP);}
if(Ask<=enterpriceSell  && !ChPos(0) && (RSIFilter==1 && rsi<=(100-rsi_ur)) && (StohasticFilter==1 && stohastic<(100-stohastic_ur) ) ) {OpenOrderOnMarket(0,TKP,STP);}
}
else{

if(Bid>=ma_line){okbuy=0;}
if(Ask<=ma_line){oksell=0;}

if(Bid>=enterpriceBuy   && oksell==0 && RSIFilter==0  && StohasticFilter==0){oksell=1;OpenOrderOnMarket(1,TKP,STP);}
if(Ask<=enterpriceSell  && okbuy==0 && RSIFilter==0  && StohasticFilter==0){okbuy=1;OpenOrderOnMarket(0,TKP,STP);}

if(Bid>=enterpriceBuy   && oksell==0 && (RSIFilter==1 && rsi>=rsi_ur) && StohasticFilter==0)       {oksell=1;OpenOrderOnMarket(1,TKP,STP);}
if(Ask<=enterpriceSell  && okbuy==0 && (RSIFilter==1 && rsi<=(100-rsi_ur) ) && StohasticFilter==0){okbuy=1;OpenOrderOnMarket(0,TKP,STP);}

if(Bid>=enterpriceBuy   && oksell==0 && RSIFilter==0  && ( StohasticFilter==1 && stohastic>stohastic_ur))      {oksell=1;OpenOrderOnMarket(1,TKP,STP);}
if(Ask<=enterpriceSell  && okbuy==0 && RSIFilter==0  && ( StohasticFilter==1 && stohastic<(100-stohastic_ur))){okbuy=1;OpenOrderOnMarket(0,TKP,STP);}

if(Bid>=enterpriceBuy   && oksell==0 && (RSIFilter==1 && rsi>=rsi_ur) && (StohasticFilter==1 && stohastic>stohastic_ur) )              {oksell=1;OpenOrderOnMarket(1,TKP,STP);}
if(Ask<=enterpriceSell  && okbuy==0 && (RSIFilter==1 && rsi<=(100-rsi_ur)) && (StohasticFilter==1 && stohastic<(100-stohastic_ur) ) ) {okbuy=1;OpenOrderOnMarket(0,TKP,STP);}

}



//---- ������ ��� ����� ��� ��������, ��� �� ������� ��� �� ������ ��� �� ����� �����

switch(close_type)
  {
   case 0:
      if(Bid>=ma_line){_OrderClose(0);}
      if(Ask<=ma_line){_OrderClose(1);}
      break;
   case 1:
    if(Bid>=proceclosesell){_OrderClose(0);}
    if(Ask<=priceclosebuy){_OrderClose(1);}    
    break;
   case 2:
    if(Bid>=proceclosesell){_OrderClose(0);}
    if(Ask<=priceclosebuy){_OrderClose(1);}  
    break;
   case 3:
    if(Bid>=bb_yellow_line_up){_OrderClose(0);}
    if(Ask<=bb_yellow_line_dw){_OrderClose(1);}  
    break;
   case 4:
    if(Bid>=bb_blue_line_up){_OrderClose(0);}
    if(Ask<=bb_blue_line_dw){_OrderClose(1);}  
    break;
   case 5:
    if(Bid>=bb_red_line_up){_OrderClose(0);}
    if(Ask<=bb_red_line_dw){_OrderClose(1);}  
      break;
   case 6:
    if(RSIFilter==1 && rsi>=rsi_ur)      {_OrderClose(0);}
    if(RSIFilter==1 && rsi<=(100-rsi_ur)){_OrderClose(1);}  
      break;
   case 7:
    if(StohasticFilter==1 && stohastic>stohastic_ur){_OrderClose(0);}
    if(StohasticFilter==1 && stohastic<(100-stohastic_ur)){_OrderClose(1);}  
      break;     
   default:
      break;
  }

//---- ������ ��� ������� ��� ��������� �������� �� RSI � ����������
   
 //----
   return(0);
  }
  
  //��������� ��� ������� �� ����
int CloseAllPos(int type)
{//�������� �������: http://fxnow.ru/blog.php?user=Yuriy&blogentry_id=72
int buy=1; int sell=1;
int i,b=0;int ordertiket;
 
 if(type==1)
   {
   while(buy==1)
     {
        buy=0;
        for( i=0;i<OrdersTotal();i++)
         {
           if(true==OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
           {
           if(OrderType()==OP_BUY && OrderSymbol()==Symbol() ){buy=1; OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet);}
           }else{buy=0;}
         }  
         if(buy==0){return(0);}
      } 
   }
   
   if(type==0)
   {
      while(sell==1)
     {
        sell=0;
        for( i=0;i<OrdersTotal();i++)
         {
           if(true==OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
           {
           if(OrderType()==OP_SELL && OrderSymbol()==Symbol() ){sell=1;OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); }
           }else{sell=0;}
         }  
         
        if(sell==0){return(0);}
      } 
     }
   return(0);
   }
  

int _OrderClose(int type)
   {
   
   int err;
   for(int i=1; i<=OrdersTotal(); i++)          
     {
      if (OrderSelect(i-1,SELECT_BY_POS)==true) 
        {
         if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && type==0 && OrderMagicNumber()==magic)
         {
          err=OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); 
          if(err<0){Print("OrderClose()-  ������ �������� OP_BUY.  OrderTicket "+OrderTicket()+" OrderLots() "+OrderLots()+" Bid "+Bid+" "+GetLastError());return(-1);}
         }
         if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && type==1 && OrderMagicNumber()==magic)
         {
          err=OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); 
          if(err<0){Print("OrderClose()-  ������ �������� OP_SELL.  OrderTicket "+OrderTicket()+" OrderLots() "+OrderLots()+" Ask "+Ask+" "+GetLastError());return(-1);}
         }
        }
       }
   return(0);
   }
  

int ChPos(int type) 
{

   int i;bool col=false;
   for( i=1; i<=OrdersTotal(); i++)         
   {
      if(OrderSelect(i-1,SELECT_BY_POS)==true) 
       {                                   
           if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && type==0&& OrderMagicNumber()==magic){col=true;}
           if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && type==1&& OrderMagicNumber()==magic){col=true;}
       }
    }   
return(col);
}

int OpenOrderOnMarket(int type,int slpips,int tppips)
{double op,sl,tp;int err;
   
   if(type==0)
   {
   op=Ask;if(slpips>0){sl=op-slpips*Point;}if(tppips>0){tp=op+tppips*Point;}
   err=OrderSend(Symbol(),OP_BUY,InpLots,NormalizeDouble(op,Digits),3,0,0,comment,magic,0,Red);
   
    if (err>0)
     {
       if (OrderSelect (err,SELECT_BY_TICKET,MODE_TRADES) == true) // �������� ����� ��� �����������
           OrderModify (err,OrderOpenPrice(),sl,tp,0); // ������������ �� � �� ��� ��� ������
           
           }
   if(err<0){Print("OrderSend()-  ������ OP_BUY.  op "+op+" sl "+sl+" tp "+tp+" "+GetLastError());return(-1);}
   }
   
   if(type==1)
   {
    op=Bid;if(slpips>0){sl=op+slpips*Point;}if(tppips>0){tp=op-tppips*Point;}
    err=OrderSend(Symbol(),OP_SELL,InpLots,NormalizeDouble(op,Digits),3,0,0,comment,magic,0,Red);
    if (err>0)
     {
       if (OrderSelect (err,SELECT_BY_TICKET,MODE_TRADES) == true) // �������� ����� ��� �����������
           OrderModify (err,OrderOpenPrice(),sl,tp,0); // ������������ �� � �� ��� ��� ������
           
           }
    if(err<0){Print("OrderSend()-  ������ OP_SELL.  op "+op+" sl "+sl+" tp "+tp+" "+GetLastError());return(-1);}
   }
return(0);
}
  

int init()
  {

   return(0);
  }

int deinit()
  {

   return(0);
  }

