/**
* Conway's Game of Life Cell
*
* data_i[7:0] is status of 8 neighbor cells
* data_o is status this cell
* 1: alive, 0: death
*
* when en_i==1:
*   simulate the cell transition with 8 given neighors
* else when update_i==1:
*   update the cell status to update_val_i
* else:
*   cell status remains unchanged
**/

module bsg_cgol_cell (
    input clk_i

    ,input en_i          
    ,input [7:0] data_i

    ,input update_i     
    ,input update_val_i

    ,output logic data_o
  );

  // TODO: Design your bsg_cgl_cell
  // Hint: Find the module to count the number of neighbors from basejump
  logic current_val, next_val;
  wire [3:0] count;
  
  assign data_o = current_val;

//   bsg_thermometer_count #(.width_p(8)) count_adj (.i(data_i), .o(count));
    bsg_popcount #(.width_p(8)) count_adj (.i(data_i), .o(count));

    always @(posedge clk_i) begin
        current_val <= next_val;
    end
    
    always_comb begin
        if (en_i && update_i || !en_i && !update_i) begin
            next_val = current_val;
        end
        else if (en_i) begin
            if (count == 3 || count == 2 && current_val == 1)
                next_val = 1;
            else
                next_val = 0;
        end
        // if (update_i)
        else begin
            next_val = update_val_i;
        end
    end




endmodule
