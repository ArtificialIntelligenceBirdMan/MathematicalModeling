#include<iostream>
#include<cstdio>
#include<string>
#include<cstring>
#include<vector>
#include<algorithm>
#include<fstream>
#include<map>
using namespace std;
#define WAIT0   0       // 没有熟料的等待
#define WAIT1   1       // cnc上有一块熟料
#define PROC    2
#define REPAIR  3
#define BROKEN  4
#define ALL     0       // 全能型CNC（相当于第一问中的CNC）
#define ONE     1
#define TWO     2

int global_time;
default_random_engine e(0);         // 种子设置为0
map<int, vector<int>> broken_info;  // 存储故障信息
int mes[3];         // 等待rgv处理的cnc的个数，也即当前rgv收到的消息数，mes1和2对应两类CNC
struct CNC{
    int id;         // 编号{1,2,3,4,5,6,7,8}
    int type;       // 型号{0,1,2}
    int pos;        // 位置{1,2,3,4}
    int state;      // 状态{0或1：等待cnc, 2：加工中, 3：修理中, 4：将要损坏}，其中0表示cnc上没有板
    int time;       // 如果处于0或1状态，则表示已经等待了的时间，如果处于2，表示距离加工完成所需的时间
    int num;        // 加工物料的编号
    int proc_time;  // 加工物料所需时间

    // 构造函数
    CNC(int i, int pt, int ty) : id(i), type(ty), pos((i+1)/2), state(WAIT0), time(0), num(0), proc_time(pt) {}
    CNC(int i, int pt) : id(i), type(0), pos((i+1)/2), state(WAIT0), time(0), num(0), proc_time(pt) {}
    CNC() : CNC(0, 560) {}      // 委托构造函数

    // 模拟cnc处理t秒（加工或者等待或者修理）
    // 输入：t  表示处理的时间
    // 返回：int 处理完成后的状态
    int proc(int t)
    {
        if(state < 2)
            time += t;
        else if(state == PROC){
            time -= t;
            if(time <= 0){
                state = WAIT1;
                time = -time;
                mes[type]++;
            }
        }
        else if(state == REPAIR){
            time -= t;
            if(time <= 0){
                broken_info[num].push_back(global_time + time);     // 故障修好的时间
                state = WAIT0;      // 修理完成后CNC上面是没有物料的
                num = 0;
                time = -time;
                mes[type]++;
            }
        }
        else if(state == BROKEN){
            time -= t;
            if(time <= 0){
                vector<int> bt(1, id);                  // 发生故障机器对应的CNC编号
                bt.push_back(global_time + time);       // 故障开始的时间
                broken_info[num] = bt;
                state = REPAIR;         // 修理时间介于10分钟到20分钟之间
                uniform_int_distribution<int> u(600, 1200);  // 使用均匀分布是否不妥？
                time = u(e) + time;     // 因为此时time已经小于0了
            }
        }
        return state;
    }

    // 模拟状态改变，即更换物料
    // 输入：n     新放上的物料的编号
    // 返回：int   处理完成后的状态
    int change(int n)
    {
        uniform_int_distribution<int> u(0, 100 * proc_time - 1);
        int broken_time = u(e);     // 指运行多长时间会损坏，这里因为设置了随机数范围是0~100*proc_time，所以概率是0.01
        if(broken_time < proc_time){
            num = n;
            state = BROKEN;
            time = broken_time;
            mes[type]--;
        }
        else{
            num = n;
            state = PROC;
            time = proc_time;
            mes[type]--;
        }
        return state;
    }
};

struct RGV{
    int time;           // 从开始运行到当前的时间
    int pos;            // 位置{1,2,3,4}
    int n1, n2, n3;     // n1生料, n2清洗槽中存放的物料编号 {0,1,2,...}，其中0表示没有物料, n3表示半熟料（只进行了工序1）
    int move_time[4] = {0, 20, 33, 46};     // 默认是第一组的数据
    int change_time[10] = {0, 28, 31, 28, 31, 28, 31, 28, 31, 0};
    const int clean_time = 25;

    // 构造函数
    RGV(int *a, int *b, int cl) : time(0), pos(1), n1(0), n2(0), n3(0), clean_time(cl)
    {
        for(int i=0;i<4;i++)
            move_time[i] = a[i];
        for(int i=0;i<10;i++)
            change_time[i] = b[i];
    }
    RGV() : time(0), pos(1), n1(0), n2(0), n3(0) {}

    // change模拟rgv从当前位置去到n号cnc机器并完成上下料这一系列工作
    // 输入：n  表示待处理的cnc编号
    // 返回：int  这一过程的时间
    int change(int n)
    {
        n1++;           //拿来一块新的生料
        int total_time = change_time[n];
        time += total_time;
        global_time = time;
        return total_time;
    }

    // move_to模拟rgv移动
    // 输入：n  表示待处理的cnc编号
    // 返回：int 这一过程的时间
    int move_to(int n)
    {
        int t = move_time[abs((n+1)/2 - pos)];
        time += t;
        pos = abs((n+1)/2);
        global_time = time;
        return t;
    }


    // clean模拟rgv清洗工作
    // 输入:num 此时机械臂上的物料编号
    // 返回：清洗完放上下料传送带的物料的编号
    int clean(int num)
    {
        int finish = n2;
        n2 = num;
        time += clean_time;
        global_time = time;
        return finish;
    }

    // wait模拟rgv原地等待
    // 输入：t   等待的时间
    // 返回：int 等待的时间
    int wait(int t)
    {
        time += t;
        global_time = time;
        return time;
    }
} *rgv_ptr;

// 物料
struct matter{
    int cnc_number = -1;
    int start_time = -1;
    int leave_cnc = -1;
    int cnc_number2 = -1;
    int start_time2 = -1;   // 第二道工序开始和离开时的时间
    int leave_cnc2 = -1;
    int finish_time = -1;
    int is_broken = -1;     // -1表示没有报废，0表示报废了
} mt[1000];

int find_cnc(vector<CNC>, int p, int ty);

int problem3_1(RGV &rgv, vector<CNC> &cnc, const string file_name)
{
    memset(mt, -1, sizeof(mt));         // 这里-1是对的，但-2或者其他可能不对了，因为单位是char
    broken_info.clear();
    global_time = 0;
    ofstream out(file_name);
    ofstream out2(file_name.substr(0, file_name.find('.')) + "_broken_info.txt");
    mes[0] = 8;
    while(rgv.time <= 28800){
        if(mes[0]){                        // 有cnc处于等待状态
            int n = find_cnc(cnc, rgv.pos, ALL);
            int t = rgv.move_to(n);
            for(int i=1;i<=8;i++)
                cnc[i].proc(t);
            if(!(n%2) && cnc[n-1].state < 2)
                n--;        // 如果到了这里发现，这个偶数号机器对面的机器也好了，那就先处理奇数号的
            mt[rgv.n1 + 1].start_time = rgv.time;   // 这里rgv.n1+1表示接下来即将放上去的新的物料的编号
            mt[rgv.n1 + 1].cnc_number = n;
            int down = cnc[n].num;      // 取下的熟料
            mt[down].leave_cnc = rgv.time;
            t = rgv.change(n);
            for(int i=1;i<=8;i++)
                cnc[i].proc(t);
            cnc[n].change(rgv.n1);
            if(down){                   // 如果down不为0，说明取下了熟料，要清洗
                int finish = rgv.clean(down);
                for(int i=1;i<=8;i++)
                    cnc[i].proc(rgv.clean_time);
                mt[finish].finish_time = rgv.time;
                if(finish){             // 如果finish不为0，说明从清洗槽中取出了成料
//                    printf("%d finish at %d s\n", finish, rgv.time);
//                    cout << finish << " " << rgv.time << endl;
                }
            }
        }
        else{                           //所有cnc都在加工，没有等待的cnc
            int min_t = 600;            //下面先找到最快哪个cnc能加工好，因为最大不可能超过600，所以先设置为600
            for(int i=1;i<=8;i++)
                if(cnc[i].time < min_t)
                    min_t = cnc[i].time;
            rgv.wait(min_t);
            for(int i=1;i<=8;i++)
                cnc[i].proc(min_t);
        }
    }
    for(int i=0;i<1000;i++){
        if(mt[i].cnc_number > 0){
            out << i << " " << mt[i].cnc_number << " " << mt[i].start_time << " " << mt[i].leave_cnc << " " << mt[i].finish_time << endl;
        }
    }
    for(auto v : broken_info)
        out2 << v.first << " " << v.second[0] << " " << v.second[1] << " " << v.second[2] << endl;
    out.close();
    out2.close();
    return 0;
}

int problem3_2(RGV &rgv, vector<CNC> &cnc, const string file_name)
{
    rgv.time = rgv.n1 = rgv.n2 = rgv.n3 = 0;
    rgv.pos = 1;
    memset(mes, 0, sizeof(mes));
    memset(mt, -1, sizeof(mt));
    broken_info.clear();
    global_time = 0;
    ofstream out(file_name);
    ofstream out2(file_name.substr(0, file_name.find('.')) + "_broken_info.txt");
    for(int i=1;i<=8;i++)
        mes[cnc[i].type]++;
    while(rgv.time <= 28800){
        if(rgv.n3){
            if(mes[TWO]){                        // 有第二道工序的cnc处于等待状态
                int n = find_cnc(cnc, rgv.pos, TWO);
                int t = rgv.move_to(n);
                for(int i=1;i<=8;i++)
                    cnc[i].proc(t);
                if(!(n%2) && cnc[n-1].type == TWO && cnc[n-1].state < 2)
                    n--;        // 如果到了这里发现，这个偶数号机器对面的机器也好了，那就先处理奇数号的
                mt[rgv.n3].start_time2 = rgv.time;   // 这里rgv.n3表示半熟料的编号
                mt[rgv.n3].cnc_number2 = n;
                int down = cnc[n].num;      // 取下的熟料
                mt[down].leave_cnc2 = rgv.time;
                t = rgv.change(n);
                rgv.n1--;
                for(int i=1;i<=8;i++)
                    cnc[i].proc(t);
                cnc[n].change(rgv.n3);
                if(down){                   // 如果down不为0，说明取下了熟料，要清洗
                    int finish = rgv.clean(down);
                    for(int i=1;i<=8;i++)
                        cnc[i].proc(rgv.clean_time);
                    mt[finish].finish_time = rgv.time;
                    if(finish){             // 如果finish不为0，说明从清洗槽中取出了成料
//                        printf("%d finish at %d s\n", finish, rgv.time);
//                        cout << finish << " " << rgv.time << endl;
                    }
                }
                rgv.n3 = 0;         // 不管有没有洗，现在rgv手上都没有料了（或者说只有生料，接下来等一类cnc）
            }
            else{                           //所有二类cnc都在加工，没有等待的cnc
                int min_t = 600;            //下面先找到最快哪个二类cnc能加工好，因为最大不可能超过600，所以先设置为600
                for(int i=1;i<=8;i++)
                    if(cnc[i].type == TWO && cnc[i].time < min_t)
                        min_t = cnc[i].time;
                rgv.wait(min_t);
                for(int i=1;i<=8;i++)
                    cnc[i].proc(min_t);
            }
        }
        else{
            if(mes[ONE]){
                int n = find_cnc(cnc, rgv.pos, ONE);
                int t = rgv.move_to(n);
                for(int i=1;i<=8;i++)
                    cnc[i].proc(t);
                if(!(n%2) && cnc[n-1].type == ONE && cnc[n-1].state < 2)
                    n--;        // 如果到了这里发现，这个偶数号机器对面的机器也好了，那就先处理奇数号的
                mt[rgv.n1 + 1].start_time = rgv.time;
                mt[rgv.n1 + 1].cnc_number = n;
                int down = cnc[n].num;      // 取下的熟料
                mt[down].leave_cnc = rgv.time;
                t = rgv.change(n);
                for(int i=1;i<=8;i++)
                    cnc[i].proc(t);
                cnc[n].change(rgv.n1);
                rgv.n3 = down;              //开始去找二类cnc
            }
            else{                           //所有一类cnc都在加工，没有等待的cnc
                int min_t = 600;            //下面先找到最快哪个一类cnc能加工好，因为最大不可能超过600，所以先设置为600
                for(int i=1;i<=8;i++)
                    if(cnc[i].type == ONE && cnc[i].time < min_t)
                        min_t = cnc[i].time;
                rgv.wait(min_t);
                for(int i=1;i<=8;i++)
                    cnc[i].proc(min_t);
            }
        }
    }
    for(int i=0;i<1000;i++){
        if(mt[i].cnc_number > 0){
            out << i << " " << mt[i].cnc_number << " " << mt[i].start_time << " " << mt[i].leave_cnc << " "
                << mt[i].cnc_number2 << " " << mt[i].start_time2 << " " << mt[i].leave_cnc2 << " " << mt[i].finish_time << endl;
        }
    }
    for(auto v : broken_info)
        out2 << v.first << " " << v.second[0] << " " << v.second[1] << " " << v.second[2] << endl;
    out.close();
    out2.close();
    return 0;
}

bool cmp(const CNC &a, const CNC &b, int p, int type)
{
    if(a.type != type) return false;
    else if(b.type != type) return true;
    else{
        if(a.state > 1) return false;
        else if(b.state > 1) return true;
        else{
            if(abs(a.pos - p) < abs(b.pos - p)) return true;
            else if(abs(a.pos - p) > abs(b.pos - p)) return false;
            else{
                if((a.pos % 2) && !(b.pos % 2)) return true;
                else if(!(a.pos % 2) && (b.pos % 2)) return false;
                else{
                    return (a.time > b.time);
                }
            }
        }
    }
}

// 输入的是8个cnc组成的vector， rgv的位置p，以及要寻找的cnc的类型ty
int find_cnc(vector<CNC> t, int p, int ty)
{
    auto it = min_element(t.begin() + 1, t.end() - 1,
                  [p, ty](const CNC &a, const CNC &b){return cmp(a, b, p, ty);});
    return (it - t.begin());
}

int main()
{
    int move_time[3][4] = {{0, 20, 33, 46}, {0, 23, 41, 59}, {0, 18, 32, 46}};
    int change_time[3][10] = {{0, 28, 31, 28, 31, 28, 31, 28, 31, 0},
                                    {0, 30, 35, 30, 35, 30, 35, 30, 35, 0},
                                    {0, 27, 32, 27, 32, 27, 32, 27, 32, 0}};
    int clean_time[3] = {25, 30, 25};
    int proc_time[3][3] = {{560, 400, 378}, {580, 280, 500}, {545, 455, 182}};

    RGV rgv1(move_time[0], change_time[0], clean_time[0]);
    RGV rgv2(move_time[1], change_time[1], clean_time[1]);
    RGV rgv3(move_time[2], change_time[2], clean_time[2]);
    vector<CNC> cnc(10);
    for(int i=1;i<=8;i++){
        CNC t(i, proc_time[0][0]);
        cnc[i] = t;
    }
    problem3_1(rgv1, cnc, "output3-1-1.txt");           // 解决第三问一道工序第一组
    printf("Finish output3-1\n");
    for(int i=1;i<=8;i++){
        CNC t(i, proc_time[1][0]);
        cnc[i] = t;
    }
    problem3_1(rgv2, cnc, "output3-1-2.txt");           // 解决第三问一道工序第二组
    printf("Finish output3-2\n");
    for(int i=1;i<=8;i++){
        CNC t(i, proc_time[2][0]);
        cnc[i] = t;
    }
    problem3_1(rgv3, cnc, "output3-1-3.txt");           // 解决第三问一道工序第三组
    printf("Finish output3-3\n");

    // 解决第三问两道工序第一组
    for(unsigned j=0;j<8;j++){
        CNC t(j+1, proc_time[0][(86>>j)%2 + 1], (86>>j)%2 + 1);
        cnc[j+1] = t;
    }
    problem3_2(rgv1, cnc, "output3-2-1.txt");
    printf("Finish output3-2-1\n");

    // 解决第三问两道工序第二组
    for(unsigned j=0;j<8;j++){
        CNC t(j+1, proc_time[1][(85>>j)%2 + 1], (85>>j)%2 + 1);
        cnc[j+1] = t;
    }
    problem3_2(rgv2, cnc, "output3-2-2.txt");
    printf("Finish output3-2-2\n");

    // 解决第三问两道工序第二组
    for(unsigned j=0;j<8;j++){
        CNC t(j+1, proc_time[2][(81>>j)%2 + 1], (81>>j)%2 + 1);
        cnc[j+1] = t;
    }
    problem3_2(rgv3, cnc, "output3-2-3.txt");
    printf("Finish output3-2-3\n");

    return 0;
}
