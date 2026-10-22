module tb_fir;
    logic clk = 0;
    logic rst_n;
    logic signed [15:0] data_in;
    logic valid_in;
    logic signed [15:0] data_out;
    logic valid_out;

    fir_filter dut (.*);
    always #5 clk = ~clk; 

    integer fd, r;
    logic [15:0] in_vec, expected_out;
    integer errors = 0;
    integer tests = 0;
    integer i;

    initial begin
        fd = $fopen("tb_vectors.txt", "r");
        if (fd == 0) begin $display("ERR"); $finish; end
        
        rst_n = 0;
        valid_in = 0;
        data_in = 0;
        #20;
        rst_n = 1;
        #20;

        for (i = 0; i < 50; i = i + 1) begin
            r = $fscanf(fd, "%h %h", in_vec, expected_out);
            if (r == 2 && i >= 8) begin
                data_in = in_vec;
                valid_in = 1;
                @(posedge clk);
                valid_in = 0;
                
                repeat(12) @(posedge clk);
                
                tests++;
                if (data_out !== $signed(expected_out)) begin
                    $display("MISMATCH: In=%h Out=%h Exp=%h", in_vec, data_out, expected_out);
                    errors++;
                end
            end
        end
        $display("----------------------------------------");
        $display("Tests: %0d, Errors: %0d", tests, errors);
        if (errors == 0) $display("STATUS: PASS");
        else $display("STATUS: FAIL");
        $finish;
    end
endmodule
