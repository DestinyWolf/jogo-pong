module main(linhas, colunas, btn, sw, clk, display0, display1);
	
	localparam IN_MENU = 2'b00;
	localparam RUNNING = 2'b01;
	localparam PAUSED = 2'b10;
	localparam FINISHED = 2'b11;

	localparam CALL_ME_BABY = 2'b00;
	localparam CAN_I_TRY_SOMETHING_DIFFERENT = 2'b01;
	localparam HARD = 2'b10;
	localparam I_LOST_MY_LIFE = 2'b11;

	input [11:0] btn;
	input [3:0] sw;
	input clk;
	output reg [4:0] colunas;
	output reg [7:0] linhas;
	output reg [6:0] display0, display1;
	
	wire clk_05ms, clk_60, clk_120, clk_30, clk_15, clk_3, clk_4;
	wire key1, key2, key3;

	wire inc_x, rst_y;
	
	wire [2:0] bol_pos_x, bol_pos_y;
	wire sentido;
	wire rst_count;
	wire clk_to_game;
	
	wire [4:0] jogador_pos;
	wire [2:0] pos_y;
	
	wire [2:0] pos_jogador;
	wire rst;
	wire [7:0] linha0, linha1, linha2, linha3, linha4;
	wire [7:0] line_bol_player;
	wire rst_player;
	wire colision_p_b;
	wire player_lost;
	reg start;


	reg [1:0] game_state;
	reg [1:0] game_dificult;
	reg [6:0] points;
	wire game_speed;
	wire player_clk;
	reg on_running_game;

	assign clk_to_game = clk_15 & on_running_game;
	assign player_clk = clk_120 & on_running_game;

	dbouncer db1(btn[0], clk_120, key1, rst);
	dbouncer db2(btn[1], clk_120, key2, rst);
	dbouncer db3(btn[2], clk_120, key3, rst);
	
	
	assign game_speed = clk_15;
	
	assign rst = sw[3];
	
	reg game_rst;
	wire clk_to_sft_reg;
	wire [6:0] bol_pos_line;
	wire [4:0] pos_y_jogador;
	
	//podemos alterar depois
	divisor_de_frequencia main_clk_div(clk, clk_05ms, clk_60, clk_120, clk_30, clk_15, clk_3, clk_4);
	
	wire up, down;

	//ja esta funcionando
	assign up = (key3 & pos_jogador < 3'b100) ? 1'b1:1'b0;
	assign down = (key2 & pos_jogador > 3'b000) ? 1'b1:1'b0;
	
	//contador da posição do jogador
	count_3b counter_jogador(up, down, player_clk, game_rst & key1, pos_jogador);
	
	assign sentido = (pos_y == 3'b001) ? 1'b1: ((pos_y == 3'b110) ? 1'b0:sentido);
	

	count_3b pos_bol_y(sentido, !sentido, clk_to_game, game_rst & key1, pos_y);
	
	//transforma a contagem em um bit da linha da bola
	assign bol_pos_line[0] =  1'b0;
	assign bol_pos_line[1] = (pos_y == 3'b001) ? 1'b0:1'b1;
	assign bol_pos_line[2] = (pos_y == 3'b010) ? 1'b0:1'b1;
	assign bol_pos_line[3] = (pos_y == 3'b011) ? 1'b0:1'b1;
	assign bol_pos_line[4] = (pos_y == 3'b100) ? 1'b0:1'b1;
	assign bol_pos_line[5] = (pos_y == 3'b101) ? 1'b0:1'b1;
	assign bol_pos_line[6] = (pos_y == 3'b110) ? 1'b0:1'b1;

	//transforma o contador da posição do jogador em um bit da coluna
	assign pos_y_jogador[0] = (pos_jogador == 3'b000) ? 1'b0:1'b1;
	assign pos_y_jogador[1] = (pos_jogador == 3'b001) ? 1'b0:1'b1;
	assign pos_y_jogador[2] = (pos_jogador == 3'b010) ? 1'b0:1'b1;
	assign pos_y_jogador[3] = (pos_jogador == 3'b011) ? 1'b0:1'b1;
	assign pos_y_jogador[4] = (pos_jogador == 3'b100) ? 1'b0:1'b1;

	wire bol_pos_7;
	wire clk_to_count;
	
	assign clk_to_count = clk_to_game;
	
	
	//define o que ira aparecer em cada linha (nem sei como eh que isso ainda funciona)
	assign linha0 = (bol_pos_x == 3'b000) ? {pos_y_jogador[0], bol_pos_line}:{pos_y_jogador[0], 7'b1111110};
	assign linha1 = (bol_pos_x == 3'b001) ? {pos_y_jogador[1], bol_pos_line}:{pos_y_jogador[1], 7'b1111110};
	assign linha2 = (bol_pos_x == 3'b010) ? {pos_y_jogador[2], bol_pos_line}:{pos_y_jogador[2], 7'b1111110};
	assign linha3 = (bol_pos_x == 3'b011) ? {pos_y_jogador[3], bol_pos_line}:{pos_y_jogador[3], 7'b1111110};
	assign linha4 = (bol_pos_x == 3'b100) ? {pos_y_jogador[4], bol_pos_line}:{pos_y_jogador[4], 7'b1111110};
	
	assign inc_x = (bol_pos_x == 3'b100) ? 1'b0: (bol_pos_x == 3'b000 ? 1'b1:inc_x);
	
	
	//reset do eixo y da bola
	assign rst_y = bol_pos_y[2] & !bol_pos_y[1] & bol_pos_y[0];
	
	//contador da posicao da bola
	count_3b bol_counter_x(inc_x, !inc_x, game_speed & !game_state[1], game_rst & key1, bol_pos_x);
	

	wire [4:0] game_rows;
	wire [7:0] game_lines;

	//varredura da matriz de leds
	matriz matrix(clk_120, rst, linha0, linha1, linha2, linha3, linha4, game_lines, game_rows);
	
	//assign colision_p_b = (pos_y == 3'b110) ? (bol_pos_x == pos_jogador) ? 1'b1:1'b0:1'b0;
	//assign player_lost = (pos_y == 3'b110) ? ((bol_pos_x != pos_jogador) ? 1'b1:1'b0):1'b0;

	reg [2:0] count;
	reg lost, colision, win;

	//reestruturação da maquina de estados

	always @(posedge clk_120) begin
		if(sw[3]) begin
			game_state <= IN_MENU;
			start <= 1'b0;
			on_running_game <= 1'b0;
			game_rst<= 1'b1;
		end
		case (game_state)
			
			IN_MENU: begin
				linhas <= 8'b00000000;
				colunas <= 5'b00000;
				//led <= 4'b0001;
				on_running_game <= 1'b0;
				game_rst<= 1'b0;
				//isso aqui faz iniciar o jogo e definir a dificuldade
				if (key3) begin
					game_state <= RUNNING;
					start <= 1'b1;
					on_running_game <= 1'b1;
					game_rst <= 1'b0;
				end else if (key1) begin
					game_dificult <= game_dificult + 1;
				end else if (key2) begin
					game_dificult <= game_dificult - 1;
				end else begin
					game_dificult <= game_dificult;
					game_state <= game_state;
					on_running_game <= on_running_game;
				end
			end
			RUNNING: begin
				game_rst<= 1'b0;
				start <= 1'b0;
				on_running_game <= 1'b1;
				game_rst <= 1'b0;
				linhas <= game_lines;
				colunas <= game_rows;
				if((colision && lost) | (colision && win)) begin
					game_state <= FINISHED;
					on_running_game <= 1'b0;
					count <= 3'b000;
				end
				if (key1) begin
					on_running_game <= 1'b0;
					game_state <= PAUSED;
				end
			end
			PAUSED: begin
				linhas <= game_lines;
				colunas <= game_rows;
				game_rst<= 1'b0;
				on_running_game <= 1'b0;
				if (key2) begin
					on_running_game <= 1'b1;
					game_state <= RUNNING;
				end else if (key3) begin
					on_running_game <= 1'b0;
					game_state <= FINISHED;
				end else begin
					game_state <= PAUSED;
				end
			end
			FINISHED: begin
				on_running_game <= 1'b0;
				game_rst<= 1'b1;
				if (count >= 3'b100) begin
					linhas <= 8'b0000000;
					colunas <= 5'b00000;
				end else if(count == 3'b111) begin
					count <= 3'b000;
				end else begin
					count <= count + (1 & clk_15);
					linhas <= 8'b11111111;
					colunas <= 5'b00000;
				end
				if (key1) begin
					game_state <= IN_MENU;
					game_rst<= 1'b0;
				end else begin
					game_state <= game_state;
					game_rst<= 1'b1;
				end
			end
			default: begin
				linhas <= game_lines;
				colunas <= game_rows;
				game_rst<= game_rst;
				game_state <= game_state;
				on_running_game <= on_running_game;
				start <= start;
				game_dificult <= game_dificult;
			end
		endcase
	end

	//resolver depois essa baderna aqui
	always @(posedge clk_15) begin
		case (game_state)
			IN_MENU: begin
				points <= 7'b0;
				lost <= 1'b0;
				colision <= 1'b0;
				win <= 1'b0;
				unit <= 4'h0;
				decimal <= 4'h0;
			end
			RUNNING: begin
				if (sw[2]) begin
					points <= 7'b1100000;
					unit <= 4'h5;
					decimal <= 4'h9;
				end
				if(pos_y == 3'b110) begin
					if (pos_jogador != bol_pos_x) begin
					lost <= 1'b1;
					colision <= 1'b1;
					end else begin
					colision <= 1'b1;
					lost <= 1'b0;
					points <= points + 1;
					unit <= unit +1;
					end 

					if (unit == 4'h9) begin
						decimal <= decimal + 1;
						unit <= 4'h0;
					end
				end  else begin
					lost <= 1'b0;
					colision <= 1'b0;
				end
				if (points == 7'b1100011) begin
					win <= 1'b1;
				end else begin
					win <= 1'b0;
				end
			end
			default: begin
				colision <= colision;
				lost <= lost;
				points <= points;
				unit <= unit;
				decimal <= decimal;
				win <= win;
			end
		endcase
	end
	
	reg [3:0] unit, decimal;
	always @(points) begin

		case(unit)
			4'h0: begin
				display0 <= 7'b0111111;
			end
			4'h1: begin
				display0 <= 7'b0000110;
			end
			4'h2: begin
				display0 <= 7'b1011011;
			end
			4'h3: begin
				display0 <= 7'b1001111;
			end
			4'h4: begin
				display0 <= 7'b1100110;
			end
			4'h5: begin
				display0 <= 7'b1101101;
			end
			4'h6: begin
				display0 <= 7'b1111101;
			end
			4'h7: begin
				display0 <= 7'b0000111;
			end
			4'h8: begin
				display0 <= 7'b1111111;
			end
			4'h9: begin
				display0 <= 7'b1100111;
			end
			default: begin
				display0 <= 7'b1000000;
			end
		endcase

		case (decimal) 
			4'h0: begin
				display1 <= 7'b0111111;
			end
			4'h1: begin
				display1 <= 7'b0000110;
			end
			4'h2: begin
				display1 <= 7'b1011011;
			end
			4'h3: begin
				display1 <= 7'b1001111;
			end
			4'h4: begin
				display1 <= 7'b1100110;
			end
			4'h5: begin
				display1 <= 7'b1101101;
			end
			4'h6: begin
				display1 <= 7'b1111101;
			end
			4'h7: begin
				display1 <= 7'b0000111;
			end
			4'h8: begin
				display1 <= 7'b1111111;
			end
			4'h9: begin
				display1 <= 7'b1100111;
			end
			default: begin
				display1 <= 7'b1000000;
			end
		endcase
	end
	
endmodule