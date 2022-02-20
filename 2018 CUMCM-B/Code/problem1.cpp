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

int mes;        // 等待rgv处理的cnc的个数，也即当前rgv收到的消息数
struct CNC{
    int id;     // 编号{1,2,3,4,5,6,7,8}
    int pos;    // 位置{1,2,3,4}
    int state;  // 状态{0或1：等待cnc, 2：加工中, 3：修理中}，其中0表示cnc上没有板
    int time;   // 如果处于0或1状态，则表示已经等待了的时间，如果处于2，表示距离加工完成所需的时间
    int num;    // 加工物料的编号
    int proc_time = 560;  // 加工物料所需时间

    // 构造函数
    CNC(int i, int pt) : id(i), pos((i+1)/2), state(WAIT0), time(0), num(0), proc_time(pt)  {}
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
                mes++;
            }
        }
        return state;
    }

    // 模拟状态改变，即更换物料
    // 输入：n     新放上的物料的编号
    // 返回：int   处理完成后的状态
    int change(int n)
    {
        num = n;
        state = PROC;
        time = proc_time;
        mes--;
        return state;
    }
};

struct RGV{
    int time;           // 从开始运行到当前的时间
    int pos;            // 位置{1,2,3,4}
    int n1, n2;         // n2清洗槽中存放的物料编号 {0,1,2,...}，其中0表示没有物料, n1生料
    int move_time[4] = {0, 20, 33, 46};
    int change_time[10] = {0, 28, 31, 28, 31, 28, 31, 28, 31, 0};
    const int clean_time = 25;

    // 构造函数
    RGV(int *a, int *b, int cl) : time(0), pos(1), n1(0), n2(0), clean_time(cl)
    {
        for(int i=0;i<4;i++)
            move_time[i] = a[i];
        for(int i=0;i<10;i++)
            change_time[i] = b[i];
    }
    RGV() : time(0), pos(1), n1(0), n2(0) {}

    // change模拟rgv从当前位置去到n号cnc机器并完成上下料这一系列工作
    // 输入：n  表示待处理的cnc编号
    // 返回：int  这一过程的时间
    int change(int n)
    {
        n1++;           //拿来一块新的生料
        int total_time = change_time[n];
        time += total_time;
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
        return finish;
    }
};

// 物料
struct matter{
    int cnc_number = -1;
    int start_time = -1;
    int leave_cnc = -1;
    int finish_time = -1;
} mt[1000];

int find_cnc(vector<CNC>, int p);

int problem1(RGV &rgv, vector<CNC> &cnc, const string file_name)
{
    memset(mt, -1, sizeof(mt));         // 这里-1是对的，但-2或者其他可能不对了，因为单位是char
    ofstream out(file_name);
    mes = 8;
    while(rgv.time <= 28800){
        if(mes){                        // 有cnc处于等待状态
            int n = find_cnc(cnc, rgv.pos);
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
                    printf("%d finish at %d s\n", finish, rgv.time);
                    cout << finish << " " << rgv.time << endl;
                }
            }
        }
        else{                           //所有cnc都在加工，没有等待的cnc
            int min_t = 600;            //下面先找到最快哪个cnc能加工好，因为最大不可能超过600，所以先设置为600
            for(int i=1;i<=8;i++)
                if(cnc[i].time < min_t)
                    min_t = cnc[i].time;
            for(int i=1;i<=8;i++)
                cnc[i].proc(min_t);
            rgv.time += min_t;
        }
    }
    for(int i=0;i<1000;i++){
        if(mt[i].cnc_number > 0){
            out << mt[i].cnc_number << " " << mt[i].start_time << " " << mt[i].leave_cnc << " " << mt[i].finish_time << endl;
        }
    }
    out.close();
    return 0;
}

bool cmp(const CNC &a, const CNC &b, int p)
{
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

int find_cnc(vector<CNC> t, int p)
{
    auto it = min_element(t.begin() + 1, t.end() - 1,
                  [p](const CNC &a, const CNC &b){return cmp(a, b, p);});
    return (it - t.begin());
}

int main()
{
    int move_time[3][4] = {{0, 20, 33, 46}, {0, 23, 41, 59}, {0, 18, 32, 46}};
    int change_time[3][10] = {{0, 28, 31, 28, 31, 28, 31, 28, 31, 0},
                                    {0, 30, 35, 30, 35, 30, 35, 30, 35, 0},
                                    {0, 27, 32, 27, 32, 27, 32, 27, 32, 0}};
    int clean_time[3] = {25, 30, 25};

    RGV rgv1(move_time[0], change_time[0], clean_time[0]);
    vector<CNC> cnc(10);
    for(int i=1;i<=8;i++){
        CNC t(i, 560);
        cnc[i] = t;
    }
    problem1(rgv1, cnc, "output1-1.txt");           // 解决第一问第一组

    RGV rgv2(move_time[1], change_time[1], clean_time[1]);
    for(int i=1;i<=8;i++){
        CNC t(i, 580);
        cnc[i] = t;
    }
    problem1(rgv2, cnc, "output1-2.txt");           // 解决第一问第二组

    RGV rgv3(move_time[2], change_time[2], clean_time[2]);
    for(int i=1;i<=8;i++){
        CNC t(i, 545);
        cnc[i] = t;
    }
    problem1(rgv3, cnc, "output1-3.txt");           // 解决第一问第三组
    return 0;
}
