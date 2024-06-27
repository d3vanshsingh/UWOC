
module topcontroller(   input clk,
                        input rst,
                        input  rxd,
                        output led,
                        //input wire serial_in,
                        output txd );
    
    wire [15:0] prescale=100000000/(115200*8); //100MHz divided baud rate per second = 108
      

    wire [7:0] senddata;
    reg sendvalid=0;
    
    wire [7:0] readdata;
    wire readvalid;
    
    reg [1:0] state=0;
    
    reg [7:0] data1=0,data2=0;
    
 
assign txd = led;
//there is a uart decoder logic (rx and tx) and an addser logic in the PL. these two need to synchronise
//with each other
//uart rx and tx can be treated as blackboxes. this current module topcontroller can be used to connect the two
   
    uart uartuut(
    .clk(clk),
    .rst(rst),
    .s_axis_tdata(senddata),
    .s_axis_tvalid(sendvalid),  //tx
    .m_axis_tdata(readdata),
    .m_axis_tvalid(readvalid),  //rx
    .m_axis_tready(1),  //set to 1 always: Ready to trasmit
    .rxd(rxd), //uart controller will use this to receive data bit by bit
    .txd(txd), //uart controller will use this to send data to PC bit by bit
    .prescale(prescale)  //baud rate set

);


adder adderuut (.clk(clk),
                .data1(data1),//the adder module starts to read valid data only after the below FSM executes
//and the readvalid goes high. Readvalid goes high
                .data2(data2),
                .dataout(senddata)); //send data back to uart module when sendvalid=1, send this to PC


always @(posedge clk) begin
    if(rst==1) begin
        state=0;
        sendvalid=0;
        data1=0;
        data2=0;
    end
    
    case(state)
    
    2'b00: begin   
            sendvalid=0; //receiving data
            if(readvalid) begin  //read data only when readvalid=1 or m_axis_tvalid=1, write it to data1 of the adder
// m_axis_tvalid is made 1 by the rx module
                    state=2'b01;
                    data1=readdata;
                end
            end
    2'b01: if(readvalid) begin
            state=2'b10;
            data2=readdata;  //read data, write it to data2
            end
    2'b10: begin
               sendvalid=1;  //send the added value back. mapped to s_axis_tvalid. immediately changinf gtom state 01 to 10, assuming one cycle delay for adder to compute sum
               state=2'b00;
           end
    
    endcase

end

endmodule
