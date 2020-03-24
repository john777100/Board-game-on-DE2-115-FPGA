with open('f.dat') as file:
    temp = file.read().splitlines()
    list_words = [i.split(',') for i in temp]
    for i in list_words:
        for j in i:
            print(j)
    