param num_layers, integer, > 0;
param num_HGCs, integer, > 0;
set layers := 1..num_layers;
set HGCs := 1..num_HGCs;

/* times when layer input is available */
param input_ready_times{l in layers}, >= 0;

/* time taken to execute each layer on an HGC */
param HGC_times{l in layers}, >= 0;

/* some large constant */
param K := sum{h in HGCs} HGC_times[h];
display K;

/* transfer_times[i] refers to the time taken to transfer the input of layer i from 3PC to HGC */
param transfer_times{l in layers}, >= 0;

var allocation{l in layers, h in HGCs}, binary;
var layer_start_times{l in layers} >= 0;
var total_time >= 0;
var Y{i in layers, j in layers, h in HGCs}, binary;

minimize overall_time: total_time;

s.t. every_layer_executed_once{l in layers}: sum{h in HGCs} allocation[l,h] = 1;
s.t. data_dependency{l in layers, h in HGCs: l > 1}: layer_start_times[l] >= input_ready_times[l] + transfer_times[l] * (2-allocation[l-1,h]-allocation[l,h]);
s.t. tot{l in layers}: total_time >= layer_start_times[l]+HGC_times[l];

/* Y[i,j,h] is 1 if i scheduled before j on machine h, and 0 if j is scheduled before i */
s.t. phi{i in layers, j in layers, h in HGCs: i > j}:
	layer_start_times[i] >= layer_start_times[j] + HGC_times[j] - K * (2-allocation[i,h]-allocation[j,h]);

solve;
display total_time;
display allocation;
display layer_start_times;


data;

param num_layers := 3;
param num_HGCs := 2;
param input_ready_times :=
	1	0
	2	2
	3	6;
param HGC_times :=
	1	4
	2	8
	3	2;
param transfer_times :=
	1	0
	2	1
	3	2;

end;
