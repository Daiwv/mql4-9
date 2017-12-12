//+------------------------------------------------------------------+
//|                                            EA_ROLL_2.1 Swing.mq4 |
//|                                Copyright 2013, drivermql@mail.ru |
//|                       drivermql@mail.ru  http://stavmany.ru/forex|
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, stavmany.ru"
#property link      "drivermql@mail.ru  http://stavmany.ru/forex/"
extern double Lots         = 0.01;         
extern int    TakeProfit   = 50;            
extern int    Step         = 150;              
extern double Multiolier   = 1.5;            
extern int    Magic        = 180813;   
extern int    Slippage     = 50;             
int ticket ;           
extern int    MaxOrders    = 50;                    
double price, TP, LastLot, minprice, maxprice, LastLots, dev1,dev2; 
                
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
 int init()
  {
  if (Digits == 3 || Digits == 5)
  {
  TakeProfit *= 10;
  Step       *= 10;
  Slippage   *= 10;
  }
    return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {

   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//+----------------��������� ������ �� ���������� Deviation---------------------------------------------+  
     dev1 = iCustom(Symbol(),30,"Deviation",2,0); // ������������ ���������� �����
     dev2 = iCustom(Symbol(),30,"Deviation",4,0); // ������������ ���������� ����

    
     // minprice = NormalizeDouble(GetMinPrice(),Digits);
    //  maxprice = NormalizeDouble(GetMaxPrice(),Digits);

//+----------------����; 1---------------------------------------------+    
          
          
          if (Ask<=dev2 && CountBuy()==0)
          {
              ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage, 0, 0, "ROLL 2 - BUY", Magic,0, Blue);
              if (ticket > 0)
              {
                  TP = NormalizeDouble(Ask + TakeProfit * Point, Digits);
                  OrderModify(ticket, OrderOpenPrice(), 0, TP, 0,Blue);
              }
           }
           if(Bid>=dev1 && CountSell()==0)
           {
                   ticket =OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage, 0, 0, "ROLL 2 - SELL", Magic, 0, Red); 
                   if (ticket > 0)
                   {
                       TP = NormalizeDouble(Bid - TakeProfit * Point, Digits);
                       OrderModify(ticket, OrderOpenPrice(), 0, TP, 0, Red);
                   }
            }
       
       
 //+---------------------- ����; 3-----------------------------------+
         if((CountBuy() > 0 && CountBuy ()< MaxOrders) || (CountSell() > 0 && CountSell () < MaxOrders))
         {   
            int order_type = FindLastOrderType();
            if(order_type == OP_BUY)
            {
 //+---------------------- ����; 4-----------------------------------+
                price = FindLastPrice(OP_BUY);
                if (Ask <= price-Step * Point)
                {

                  LastLots = FindLastLots (OP_BUY); 
                  if (LastLots <= 0) return;                               //-------------����: 5--------------------//
                  LastLots = NormalizeDouble(LastLots * Multiolier, 2);                              
                  ticket = OrderSend(Symbol(), OP_BUY, LastLots, Ask, Slippage, 0, 0, "", Magic, 0, Blue);
                  if (ticket > 0)
                  ModifyOrders(OP_BUY);
                }
             } 
      
           else   if(order_type == OP_SELL)
           {
                price = FindLastPrice(OP_SELL);
                if (Bid >= price+Step * Point)
                {
                    LastLots = FindLastLots (OP_SELL);
                    if (LastLots <= 0) return;                                //-------------����: 5--------------------//
                    LastLots = NormalizeDouble(LastLots * Multiolier, 2);                              
                    ticket = OrderSend(Symbol(), OP_SELL, LastLots, Bid, Slippage, 0, 0, "", Magic, 0, Red);
                    if (ticket > 0)
                    ModifyOrders(OP_SELL);
               }
            }
           } 
 return(0);
 }
//+----------- ����; 6----------------------------------------------+
 void ModifyOrders(int otype)
{
     double avgprice = 0, order_lots=0, price = 0; 

     for(int i=OrdersTotal()-1; i>=0; i--)
     {
         if (OrderSelect (i, SELECT_BY_POS, MODE_TRADES))
         {
             if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == otype)
             {
                 price += OrderOpenPrice() * OrderLots();
                 order_lots += OrderLots();

             }

         }
     }
     avgprice = NormalizeDouble(price / order_lots, Digits);
     if (otype == OP_BUY)
     TP = NormalizeDouble(avgprice + TakeProfit * Point, Digits);
     if (otype == OP_SELL)
     TP = NormalizeDouble(avgprice - TakeProfit * Point, Digits);
     for (i=OrdersTotal()-1; i>=0; i--)
     {
          if (OrderSelect (i, SELECT_BY_POS, MODE_TRADES))
          {
              if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == otype)
              OrderModify(OrderTicket(),OrderOpenPrice(), 0, TP, 0);
          }
     }
}
//+-----------����������� �����; 5-----------------------------------+
double FindLastLots(int otype)
{
       double oldlots; 
       int oldticket;
       ticket = 0;
       
       for(int i = OrdersTotal()-1; i>=0; i--)
       {
           if(OrderSelect (i, SELECT_BY_POS, MODE_TRADES))
           {
              if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == otype)
              {
                  oldticket = OrderTicket();
                  if(oldticket > ticket)
                  {
                    oldlots = OrderLots();
                    ticket = oldticket;

                  }
              }
           }
       }
       return(oldlots);
}
 
//+-----------����������� �����; 4-----------------------------------+ 
  double FindLastPrice(int otype)  
{
        double oldopenprice;  
        int    oldticket;    
        ticket = 0;         

        for(int i = OrdersTotal()-1; i>=0; i--) 
        {
            if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))  
            {
                if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == otype)  
                {
                    oldticket = OrderTicket();  
                    if(oldticket > ticket)      
                    {
                       oldopenprice = OrderOpenPrice();   
                       ticket = oldticket;                
                     }
                }
            }
        }
        return(oldopenprice);
 }

 
//+-----------����������� �����; 3-----------------------------------+
 int FindLastOrderType()                               
{
     for(int i=OrdersTotal()-1;i>=0;i--)                           
     {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))                  
         {
             if(OrderSymbol()==Symbol()&&OrderMagicNumber()==Magic)        
             return(OrderType());                                      
         }
      }
            return(-1);
 } 
    
//�����������������   ������������� ������ ��� �����������������������
int CountBuy ()
{
   int count = 0;
   for (int trade = OrdersTotal ()-1;trade>=0; trade--)
   {
     OrderSelect (trade, SELECT_BY_POS, MODE_TRADES);
     if (OrderSymbol ()==Symbol () && OrderMagicNumber ()==Magic)
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
     if (OrderSymbol ()==Symbol () && OrderMagicNumber ()==Magic)
      {
        if (OrderType ()==OP_SELL)
        count++;
      }
    }
    
    return (count);
 }