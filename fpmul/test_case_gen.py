test_case_id_file = open("test_id_list.csv", "w")
test_case_id_file.write("Case ID,Catalogue,Input A ID,Input B ID\n")

input_id = [[1, 2, 3, 4, 5, 6], 
            [7, 8, 9, 10, 11, 12],
            [13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32]]

case_pair = []
catalogue = 1

for a_type in range(0,3):
    for b_type in range(0,3):
        case_pair.append((catalogue, a_type, b_type))
        catalogue = catalogue + 1

case_id = 1

for case in case_pair:
    for a_input_id in input_id[case[1]]:
        for b_input_id in input_id[case[2]]:
            test_case_id_file.write(",".join([str(case_id), str(case[0]), str(a_input_id), str(b_input_id)]) + "\n")
            case_id = case_id + 1

test_case_id_file.close()
