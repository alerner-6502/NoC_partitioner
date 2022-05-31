#====================== INITIALIZATION =====================

import os
import sys
import math
import copy
import decimal as dc
import datetime as dt

import PARAMETERS as PAR

params = {"LVDS_DATARATE" : int, "FLIT_WIDTH" : int, "TRAFFIC_LOAD" : float,\
          "FPGA_COUNT" : int, "FPGA_DEVICES" : list, "WIRE_GRAPH" : list,\
          "ROUTER_GRAPH" : list, "OUTPUT_DIRECTORY" : str}
          
dev_params = {"DESCRIPTION" : str, "FAMILY" : str, "DEVICE" : str, "CLOCK_MHZ" : int,\
              "CLOCK_PIN" : str, "RESET_PIN" : str, "START_PIN" : str, "READY_PIN" : str,\
              "PLL_DIFF_PINS" : list, "INPUT_DIFF_PINS" : list, "OUTPUT_DIFF_PINS" : list}
              
template_files = {"async_fifo.sv", "auto_bitslip.sv", "gray_counter.sv", "lvds_reciever.v",\
                  "lvds_transmitter.v",  "reciever.sv", "rxtx_bridge_lvds.sv", "state_machine.sv",\
                  "scheduler.sv", "transmitter.sv", "main_0", "main_1", "qpf_file", "qsf_file"}
            
month_dict = { 1:"Janauary", 2:"February", 3:"March", 4:"April", 5:"May", 6:"June", 7:"July", \
               8:"August", 9:"September", 10:"October", 11:"November", 12:"December"}
            
#========================= GLOBAL PARAMETERS =====================
            
MAX_LVDS_SERIAL = 8
D_LVDS = 4
              
#============================ FUNCTIONS ==========================

def abort(message):
    print(" X\n")
    print("Issue:", message)
    print("\n"+"="*29, "ABORT", "="*30, "\n")
    sys.tracebacklimit = 0
    sys.exit()
    
def format_pair(pair):
    tmp = str(pair).replace("'", "")
    while len(tmp) < 12:
        tmp = tmp.replace(",", ", ")
    return tmp
    
#=================== CHECKING INPUT PARAMETERS ===================

print("="*20, "CHECKING INPUT PARAMETERS", "="*20, "\n")

#----- python check

print("python version ".ljust(26, '.'), end='')

if sys.version_info[0] < 3:
    abort("use python 3 or greater")
    
print(" ok")
    
#----- resources check

print("template files ".ljust(26, '.'), end='')

if not os.path.isdir("./templates"): 
    abort("\"tampletes\" folder is missing")
    
if not set(os.listdir("./templates")) >= template_files:
    abort("some files are missing from the \"templates\" folder")
    
print(" ok")

#----- basic checks

print("names and types ".ljust(26, '.'), end='')
    
for x in params.keys():

    if x not in dir(PAR): 
        abort("parameter " + x + " not found")
        
    if type(eval("PAR."+x)) is not params[x]: 
        abort("parameter " + x + " must be of type " + str(params[x]))

if PAR.FLIT_WIDTH < 4: 
    abort("FLIT_WIDTH must be greater or equal to 4")

if PAR.FPGA_COUNT < 2: 
    abort("FPGA_COUNT must be greater or equal to 2")
    
if (0.0 > PAR.TRAFFIC_LOAD) or (PAR.TRAFFIC_LOAD > 1.0):
    abort("TRAFFIC_LOAD should be a number between 0 and 1")

if PAR.FPGA_COUNT != len(PAR.FPGA_DEVICES): 
    abort("parameter FPGA_DEVICES must have " + str(PAR.FPGA_COUNT) + " items")
    
for x in PAR.FPGA_DEVICES:
    if type(x) is not dict: 
        abort("FPGA_DEVICES items must be of type " + str(dict))

if not os.path.isdir(PAR.OUTPUT_DIRECTORY): 
    abort("OUTPUT_DIRECTORY path is invalid")
    
print(" ok")    
    
#---- device dictionary checks

print("device dictionaries ".ljust(26, '.'), end='')

for x in PAR.FPGA_DEVICES:

    if not set(x.keys()) >= set(dev_params.keys()): 
        abort("some device dictionaries lack the necessary keys")
        
    for y in dev_params.keys():
    
        if type(x[y]) is not dev_params[y]: 
            abort("key " + str(y) + " in the \"" + str(x["DESCRIPTION"]) + \
                  "\" dictionary must be of type " + str(dev_params[y]))
        
        if type(x[y]) is list:
            for z in x[y]:
            
                if type(z) is not list: 
                    abort("entry for the " + str(y) + " key in the \"" + str(x["DESCRIPTION"]) + \
                          "\" dictionary should be a list of lists")
                
                if len(z) != 2:  
                    abort("sublists for the " + str(y) + " key in the \"" + str(x["DESCRIPTION"]) + \
                          "\" dictionary should have a lenght of 2")
                
                if (type(z[0]) is not str) or (type(z[1]) is not str): 
                    abort("sublists for the " + str(y) + " key in the \"" + str(x["DESCRIPTION"]) + \
                          "\" dictionary should contain strings")

print(" ok")            
            
#----- graph checks

print("wire and router graphs ".ljust(26, '.'), end='')

if PAR.FPGA_COUNT-1 != len(PAR.WIRE_GRAPH): 
    abort("WIRE_GRAPH list should have a length of " + str(PAR.FPGA_COUNT-1))

if PAR.FPGA_COUNT-1 != len(PAR.ROUTER_GRAPH): 
    abort("FPGA_COUNT list should have a length of " + str(PAR.FPGA_COUNT-1))

for x in range(PAR.FPGA_COUNT-1):

    if type(PAR.WIRE_GRAPH[x]) is not list:
        abort("parameter WIRE_GRAPH should be a list of lists")
    
    if len(PAR.WIRE_GRAPH[x]) != x+1: 
        abort("WIRE_GRAPH has invalid sublist structure")
    
    for y in PAR.WIRE_GRAPH[x]:
        if type(y) is not int:
            abort("sublists of WIRE_GRAPH must contain integers")
            
for x in range(PAR.FPGA_COUNT-1):
    
    if type(PAR.ROUTER_GRAPH[x]) is not list:
        abort("parameter ROUTER_GRAPH should be a list of lists")
    
    if len(PAR.ROUTER_GRAPH[x]) != x+1: 
        abort("ROUTER_GRAPH has invalid sublist structure")
    
    for y in PAR.ROUTER_GRAPH[x]:
        if type(y) is not int:
            abort("sublists of ROUTER_GRAPH must contain integers")
            
for x in range(PAR.FPGA_COUNT-1):
    for y in range(x+1):
        
        if (PAR.ROUTER_GRAPH[x][y] == 0) != (PAR.WIRE_GRAPH[x][y] == 0):  # logic XOR
            abort("zeros in WIRE_GRAPH should match zeros in ROUTER_GRAPH")
        
        if PAR.WIRE_GRAPH[x][y] != 0:
        
            if PAR.FLIT_WIDTH > PAR.WIRE_GRAPH[x][y]*MAX_LVDS_SERIAL:
                abort("the number of wires between FPGAs #" + str(x+1) + " and #" + str(y) + " is insufficient")
            
            if PAR.ROUTER_GRAPH[x][y]+1 > PAR.WIRE_GRAPH[x][y]*MAX_LVDS_SERIAL:
                abort("the number of wires between FPGAs #" + str(x+1) + " and #" + str(y) + " is insufficient")

print(" ok")

#----- available pin checks

print("available pins ".ljust(26, '.'), end='')

neighbors_per_fpga = [0,0,0,0]
wires_per_fpga = [0,0,0,0]

for x in range(PAR.FPGA_COUNT-1):
    for y in range(x+1):
    
        if PAR.WIRE_GRAPH[x][y] > 0:
        
            neighbors_per_fpga[x+1] += 1
            neighbors_per_fpga[y] += 1
            
            wires_per_fpga[x+1] += PAR.WIRE_GRAPH[x][y]
            wires_per_fpga[y] += PAR.WIRE_GRAPH[x][y]

for x in range(PAR.FPGA_COUNT):
    
    if len(PAR.FPGA_DEVICES[x]["PLL_DIFF_PINS"]) < neighbors_per_fpga[x]:
        abort( "\"" + PAR.FPGA_DEVICES[x]["DESCRIPTION"] + "\" (FPGA #" + str(x) + ")" \
        " does not have enough PLL pin pairs to communicate with " + str(neighbors_per_fpga[x]) + " neighbors")
    
    if len(PAR.FPGA_DEVICES[x]["INPUT_DIFF_PINS"]) < wires_per_fpga[x]:
        abort( "\"" + PAR.FPGA_DEVICES[x]["DESCRIPTION"] + "\" (FPGA #" + str(x) + ")" \
        " does not have enough INPUT pin pairs to communicate with " + str(neighbors_per_fpga[x]) + " neighbors")
        
    if len(PAR.FPGA_DEVICES[x]["OUTPUT_DIFF_PINS"]) < wires_per_fpga[x]+1:
        abort( "\"" + PAR.FPGA_DEVICES[x]["DESCRIPTION"] + "\" (FPGA #" + str(x) + ")" \
        " does not have enough OUTPUT pin pairs to communicate with " + str(neighbors_per_fpga[x]) + " neighbors")

print(" ok")

#----- lvds checks

print("lvds bitrate ".ljust(26, '.'), end='')

if (PAR.LVDS_DATARATE % 4) != 0:
    abort("LVDS_DATARATE must be divisible by 4")

for x in PAR.FPGA_DEVICES:

    if  dc.Decimal(PAR.LVDS_DATARATE) % dc.Decimal(str(x["CLOCK_MHZ"])) != 0:
        abort("LVDS datarate of " + str(PAR.LVDS_DATARATE) + " Mb/s cannot be obtained for \"" + x["DESCRIPTION"] + "\"")

print(" ok")

#=============== SEARCHING FOR OPTIMAL SOLUTION  ==============

print("\n"+"="*17, "SEARCHING FOR OPTIMAL SOLUTION", "="*18, "\n")

#----- optimal serialization factor and folds

configs = []

for S in [4,8]:

    n_list = []    # folds for every link
    f_list = []    # frequency for every link
    valid = True

    for x in range(PAR.FPGA_COUNT-1):
        for y in range(x+1):
            if (PAR.WIRE_GRAPH[x][y] > 0) and valid:
            
                flds = int((S*PAR.WIRE_GRAPH[x][y])/PAR.FLIT_WIDTH)
                
                if (flds != 0) and (PAR.FLIT_WIDTH*flds >= 1+PAR.ROUTER_GRAPH[x][y]):
                   
                        n = flds
                        n_list.append(n)
                        
                        a = PAR.LVDS_DATARATE/S 
                        b = math.ceil((2*PAR.ROUTER_GRAPH[x][y] + 1)/PAR.FLIT_WIDTH)
                        c = PAR.TRAFFIC_LOAD*PAR.ROUTER_GRAPH[x][y] + b
                        d = math.ceil(c/n) + 3.5 + D_LVDS
                        f_list.append(a/d)
                        
                else: valid = False
                
    if valid:
        configs.append([min(f_list), S, n_list])

best_config = configs[0]
for x in configs:
    if x[0] > best_config[0]:
        best_config = x
    
cnt = 0
f_graph = copy.deepcopy(PAR.WIRE_GRAPH)
for x in range(PAR.FPGA_COUNT-1):
        for y in range(x+1):
        
            if(f_graph[x][y] != 0):
                f_graph[x][y] = best_config[2][cnt]
                cnt += 1

EMU_FREQUENCY = best_config[0]
LVDS_SERIAL   = best_config[1]
FOLDS_GRAPH   = f_graph

print("Fabric frequency".ljust(20), "=", round(PAR.LVDS_DATARATE/LVDS_SERIAL, 3), "MHz")
print("Emulation frequency".ljust(20), "=", round(EMU_FREQUENCY, 3), "MHz (estimate)")
print("LVDS serialization".ljust(20), "=", LVDS_SERIAL)
print("Folds per link graph".ljust(20), "=", FOLDS_GRAPH)

#===================== ALLOCATING RESOURCES ===================

#----- allocating pins and creating configuration lists

#{PLL, IN, OUT} pin pointer counters for every FPGA
pin_pointers = [{"PLL":0, "IN":0, "OUT":0} for x in range(PAR.FPGA_COUNT)]  

pin_matches = []

config = [[] for x in range(PAR.FPGA_COUNT)]

for x in range(PAR.FPGA_COUNT-1):
    for y in range(x+1):
    
        if PAR.WIRE_GRAPH[x][y] > 0:
        
            #--- first member
            
            i_clk_0  = pin_pointers[x+1]["PLL"]
            o_clk_0  = pin_pointers[x+1]["OUT"]
            i_data_0 = range(pin_pointers[x+1]["IN"], pin_pointers[x+1]["IN"]+PAR.WIRE_GRAPH[x][y])
            o_data_0 = range(pin_pointers[x+1]["OUT"]+1, pin_pointers[x+1]["OUT"]+PAR.WIRE_GRAPH[x][y]+1)
        
            config[x+1].append( {"width" : PAR.ROUTER_GRAPH[x][y], "links" : PAR.WIRE_GRAPH[x][y], \
                                 "folds" : FOLDS_GRAPH[x][y], "neighbour_id" : y, "clk_in_pin": i_clk_0, \
                                 "clk_out_pin": o_clk_0, "data_in_pins": i_data_0, "data_out_pins": o_data_0 } )
            
            pin_pointers[x+1]["PLL"] += 1
            pin_pointers[x+1]["IN"]  += PAR.WIRE_GRAPH[x][y]
            pin_pointers[x+1]["OUT"] += PAR.WIRE_GRAPH[x][y]+1
            
            #--- second member
            
            i_clk_1  = pin_pointers[y]["PLL"]
            o_clk_1  = pin_pointers[y]["OUT"]
            i_data_1 = range(pin_pointers[y]["IN"], pin_pointers[y]["IN"]+PAR.WIRE_GRAPH[x][y])
            o_data_1 = range(pin_pointers[y]["OUT"]+1, pin_pointers[y]["OUT"]+PAR.WIRE_GRAPH[x][y]+1)
            
            config[y  ].append( {"width" : PAR.ROUTER_GRAPH[x][y], "links" : PAR.WIRE_GRAPH[x][y], \
                                 "folds" : FOLDS_GRAPH[x][y], "neighbour_id" : x+1, "clk_in_pin": i_clk_1, \
                                 "clk_out_pin": o_clk_1, "data_in_pins": i_data_1, "data_out_pins": o_data_1 } )
                                
            pin_pointers[y]["PLL"] += 1
            pin_pointers[y]["IN"]  += PAR.WIRE_GRAPH[x][y]
            pin_pointers[y]["OUT"] += PAR.WIRE_GRAPH[x][y]+1
            
            #--- pin matches
            
            pin_matches.append( [[x+1, i_clk_0, o_clk_0, i_data_0, o_data_0], \
                                 [y  , o_clk_1, i_clk_1, o_data_1, i_data_1]] )
            
            
#======================== WRITING FILES ==========================

print("\n"+"="*26, "WRITING FILES", "="*26, "\n")

#----- creating folders

print("creating folders ".ljust(26, '.'), end='')

node_paths = [PAR.OUTPUT_DIRECTORY + "/FPGA_" + str(x) for x in range(PAR.FPGA_COUNT)]

for x in node_paths:
    os.makedirs(x, exist_ok=True)
    
os.makedirs(PAR.OUTPUT_DIRECTORY + "/common", exist_ok=True)
    
print(" ok")

#----- writing MAIN.v files

print("main files ".ljust(26, '.'), end='')

for n in range(PAR.FPGA_COUNT):  # for every FPGA
    
    rf = open('./templates/main_0', mode='r')
    code  = rf.read()
    rf.close()
    
    rf = open('./templates/main_1', mode='r')
    part  = rf.read()
    rf.close()

    st0 = ""
    for x in config[n]:
        nid  = str(x["neighbour_id"])
        link = str(x["links"]-1)
        st0 += "\n\t"
        st0 += "input  i_rx_clk_" + nid + ",\n\t"
        st0 += "output o_tx_clk_" + nid + ",\n\t"
        st0 += "input  [" + link + ":0] i_rx_" + nid + ",\n\t"
        st0 += "output [" + link + ":0] o_tx_" + nid + ",\n\t"
        
    cnt = 0
    st1 = ""
    for x in config[n]:
        tmp = part
        tmp = tmp.replace("$00", str(PAR.FLIT_WIDTH-1))
        tmp = tmp.replace("$01", str(x["neighbour_id"]))
        tmp = tmp.replace("$02", str(x["width"]-1))
        tmp = tmp.replace("$03", str(PAR.FLIT_WIDTH))
        tmp = tmp.replace("$04", str(x["width"]))
        tmp = tmp.replace("$05", str(x["folds"]))
        
        tmp = tmp.replace("$06", str(x["links"]))
        tmp = tmp.replace("$07", str(PAR.LVDS_DATARATE))
        tmp = tmp.replace("$08", "\"" + str(PAR.LVDS_DATARATE)+".0 Mbps\"")
        tmp = tmp.replace("$09", str(PAR.FPGA_DEVICES[n]["CLOCK_MHZ"]))
        tmp = tmp.replace("$10", "\"" + str(PAR.FPGA_DEVICES[n]["CLOCK_MHZ"])+".000000 MHz\"")
        tmp = tmp.replace("$11", "\"" + str(int(PAR.LVDS_DATARATE/4))+".000000 MHz\"")
        tmp = tmp.replace("$12", "\"" + PAR.FPGA_DEVICES[n]["FAMILY"] + "\"")
        tmp = tmp.replace("$13", str(LVDS_SERIAL))
        tmp = tmp.replace("$14", str(cnt))
        
        st1 += tmp
        cnt += 1
        
    st2  = "//" + "-"*23 + "\n\n\t"
    st2 += "noc_" + str(n) + " noc (\n\t\t"
    st2 += ".i_rst ( i_rst   ),\n\t\t"
    st2 += ".i_clk ( EMU_CLK ),\n"
    for x in config[n]:
        nid = str(x["neighbour_id"])
        st2 += "\n\t\t"
        st2 += ".i_valids_"  + nid + " ( valids_from_node_"  + nid + " ),\n\t\t"
        st2 += ".i_credits_" + nid + " ( credits_from_node_" + nid + " ),\n\t\t"
        st2 += ".i_flits_"   + nid + " ( flits_from_node_"   + nid + " ),\n\t\t"
        st2 += ".o_valids_"  + nid + " ( valids_to_node_"    + nid + " ),\n\t\t"
        st2 += ".o_credits_" + nid + " ( credits_to_node_"   + nid + " ),\n\t\t"
        st2 += ".o_flits_"   + nid + " ( flits_to_node_"     + nid + " ),\n"
    st2 = st2[:-2] + "\n\t);\n"
        
    code = code.replace("$00", str(n))
    code = code.replace("$01", st0)   
    code = code.replace("$02", str(len(config[n])-1))   
    code = code.replace("$03", str(len(config[n])))
    code = code.replace("$04", st1)
    code = code.replace("$05", st2)
    
    wf = open(node_paths[n]+"/main.sv", mode='w')
    wf.write(code)
    wf.close()

print(" ok")

#----- writing additional verilog files

print("verilog files ".ljust(26, '.'), end='')

for n in range(PAR.FPGA_COUNT):  # for every FPGA
    for x in template_files:     # for every file in templates
        if x[-1] == 'v':         # only verilog files
    
            rf = open("./templates/"+x, mode='r')
            code  = rf.read()
            rf.close()
            
            wf = open(PAR.OUTPUT_DIRECTORY + "/common/" + x, mode='w')
            wf.write(code)
            wf.close()

print(" ok")

#----- writing QPF files

print("qpf files ".ljust(26, '.'), end='')

time = dt.datetime.now()

for n in range(PAR.FPGA_COUNT):  # for every FPGA
    
    rf = open('./templates/qpf_file', mode='r')
    code  = rf.read()
    rf.close()
    
    code = code.replace("$00", str(time.hour))
    code = code.replace("$01", str(time.minute))
    code = code.replace("$02", str(time.second))
    code = code.replace("$03", month_dict[time.month])
    code = code.replace("$04", str(time.day))
    code = code.replace("$05", str(time.year))

    wf = open(node_paths[n]+"/main.qpf", mode='w')
    wf.write(code)
    wf.close()

print(" ok")

#----- writing QSF files

print("qsf files ".ljust(26, '.'), end='')

for n in range(PAR.FPGA_COUNT):  # for every FPGA
    
    rf = open('./templates/qsf_file', mode='r')
    code  = rf.read()
    rf.close()
    
    code = code.replace("$00", PAR.FPGA_DEVICES[n]["FAMILY"])
    code = code.replace("$01", PAR.FPGA_DEVICES[n]["DEVICE"])
    code = code.replace("$02", str(time.hour))
    code = code.replace("$03", str(time.minute))
    code = code.replace("$04", str(time.second))
    code = code.replace("$05", month_dict[time.month].upper())
    code = code.replace("$06", str(time.day))
    code = code.replace("$07", str(time.year))
    
    code = code.replace("$08", PAR.FPGA_DEVICES[n]["RESET_PIN"])
    code = code.replace("$09", PAR.FPGA_DEVICES[n]["START_PIN"])
    code = code.replace("$10", PAR.FPGA_DEVICES[n]["CLOCK_PIN"])
    code = code.replace("$11", PAR.FPGA_DEVICES[n]["READY_PIN"])
    
    code += "set_global_assignment -name SYSTEMVERILOG_FILE noc_" + str(n) + ".sv\n"
    
    for x in config[n]:
    
        nid = str(x["neighbour_id"])
        
        code += "\n"
        code += "set_instance_assignment -name IO_STANDARD LVDS_E_3R -to o_tx_clk_" + nid + "\n"
        code += "set_instance_assignment -name IO_STANDARD LVDS_E_3R -to o_tx_" + nid + "\n"
        for i in range(x["links"]):
            code += "set_instance_assignment -name IO_STANDARD LVDS_E_3R -to o_tx_" + nid + "["+str(i)+"]\n"
            
        code += "\n"
        code += "set_instance_assignment -name IO_STANDARD LVDS -to i_rx_clk_" + nid + "\n"
        code += "set_instance_assignment -name IO_STANDARD LVDS -to i_rx_" + nid + "\n"
        for i in range(x["links"]):
            code += "set_instance_assignment -name IO_STANDARD LVDS -to i_rx_" + nid + "["+str(i)+"]\n"
        
        code += "\n"
        code += "set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to i_rx_clk_" + nid + "\n"
        code += "set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to \"i_rx_clk_" + nid + "(n)\"\n"
        for i in range(x["links"]):
            code += "set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to i_rx_" + nid + "["+str(i)+"]\n"
            code += "set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to \"i_rx_" + nid + "["+str(i)+"](n)\"\n"
        
        code += "\n"
        pair = PAR.FPGA_DEVICES[n]["OUTPUT_DIFF_PINS"][x["clk_out_pin"]]
        code += "set_location_assignment PIN_" + pair[0] + " -to o_tx_clk_" + nid + "\n"
        code += "set_location_assignment PIN_" + pair[1] + " -to \"o_tx_clk_" + nid + "(n)\"\n"
        for i in range(x["links"]):
            pair = PAR.FPGA_DEVICES[n]["OUTPUT_DIFF_PINS"][x["data_out_pins"][i]]
            code += "set_location_assignment PIN_" + pair[0] + " -to o_tx_" + nid + "["+str(i)+"]\n"
            code += "set_location_assignment PIN_" + pair[1] + " -to \"o_tx_" + nid + "["+str(i)+"](n)\"\n"
                
        code += "\n"
        pair = PAR.FPGA_DEVICES[n]["PLL_DIFF_PINS"][x["clk_in_pin"]]
        code += "set_location_assignment PIN_" + pair[0] + " -to i_rx_clk_" + nid + "\n"
        code += "set_location_assignment PIN_" + pair[1] + " -to \"i_rx_clk_" + nid + "(n)\"\n"
        for i in range(x["links"]):
            pair = PAR.FPGA_DEVICES[n]["INPUT_DIFF_PINS"][x["data_in_pins"][i]]
            code += "set_location_assignment PIN_" + pair[0] + " -to i_rx_" + nid + "["+str(i)+"]\n"
            code += "set_location_assignment PIN_" + pair[1] + " -to \"i_rx_" + nid + "["+str(i)+"](n)\"\n"
    
    wf = open(node_paths[n]+"/main.qsf", mode='w')
    wf.write(code)
    wf.close()

print(" ok")

#----- writing wiring file

print("wiring file ".ljust(26, '.'), end='')

wf = open(PAR.OUTPUT_DIRECTORY+"/wiring_assembly.txt", mode='w')

for x in pin_matches:
    for i in range(5):
    
        na = x[0][0]; a = x[0][i]
        nb = x[1][0]; b = x[1][i]
    
        if i == 0:
            tmp  = "-"*13 + "+" + "-"*13 + "\n"
            tmp += " FPGA " + "{:02d}".format(na).ljust(7) + "| FPGA " + "{:02d}".format(nb).ljust(7) + "\n"
            tmp += "-"*13 + "+" + "-"*13 + "\n"
            wf.write(tmp)
            
        if i == 1:
            tmp  = format_pair(PAR.FPGA_DEVICES[na]["PLL_DIFF_PINS"][a])  + " < "
            tmp += format_pair(PAR.FPGA_DEVICES[nb]["OUTPUT_DIFF_PINS"][b])  + "\n"
            wf.write(tmp)
        
        if i == 2:
            tmp  = format_pair(PAR.FPGA_DEVICES[na]["OUTPUT_DIFF_PINS"][a]) + " > "
            tmp += format_pair(PAR.FPGA_DEVICES[nb]["PLL_DIFF_PINS"][b]) + "\n"
            wf.write(tmp)
            
        if i == 3:
            for j, k in zip(a, b):
                tmp  = format_pair(PAR.FPGA_DEVICES[na]["INPUT_DIFF_PINS"][j]) + " < "
                tmp += format_pair(PAR.FPGA_DEVICES[nb]["OUTPUT_DIFF_PINS"][k]) + "\n"
                wf.write(tmp)
        
        if i == 4:
            for j, k in zip(a, b):
                tmp  = format_pair(PAR.FPGA_DEVICES[na]["OUTPUT_DIFF_PINS"][j]) + " > "
                tmp += format_pair(PAR.FPGA_DEVICES[nb]["INPUT_DIFF_PINS"][k]) + "\n"
                wf.write(tmp)
    
wf.close()

print(" ok")

#----- writing templates

print("noc templates ".ljust(26, '.'), end='')

for n in range(PAR.FPGA_COUNT):  # for every FPGA
    
    code  = "module noc_" + str(n) + " (\n\t"
    code += "input  i_rst,\n\t"
    code += "input  i_clk,\n\t"
    
    for x in config[n]:
    
        nid = str(x["neighbour_id"])
        flt = str(PAR.FLIT_WIDTH-1)
        wid = str(x["width"]-1)
        
        code += "\n\t//connections to SUBNOC #" + nid + "\n\t"
        code += "input  [" + wid + ":0] i_valids_"  + nid + ",\n\t"
        code += "input  [" + wid + ":0] i_credits_" + nid + ",\n\t"
        code += "input  [" + wid + ":0] i_flits_"   + nid + " [" + flt + ":0],\n\t"
        code += "output [" + wid + ":0] o_valids_"  + nid + ",\n\t"
        code += "output [" + wid + ":0] o_credits_" + nid + ",\n\t"
        code += "output [" + wid + ":0] o_flits_"   + nid + " [" + flt + ":0],\n"
        
    code  = code[:-2] + "\n);\n\n\t"
    code += "//USER CODE FOR SUBNOC #" + str(n) + "\n\n"
    code += "endmodule\n"
    
    wf = open(node_paths[n] + "/noc_" + str(n) + ".sv", mode='w')
    wf.write(code)
    wf.close()


print(" ok")

#=================================================================

print("\n"+"="*66, "\n")





