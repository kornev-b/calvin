module SimpleInverter(
    input wire a,
    output wire a_bar
    );
     
    assign a_bar = ~a; 
     
endmodule