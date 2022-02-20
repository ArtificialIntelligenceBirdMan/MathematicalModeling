#include<iostream>
#include<cstdio>
#include<string>
#include<cstring>
#include<vector>
#include<algorithm>
#include<fstream>
#include<map>
using namespace std;
#define WAIT0   0       // û�����ϵĵȴ�
#define WAIT1   1       // cnc����һ������
#define PROC    2
#define REPAIR  3
#define BROKEN  4
#define ALL     0       // ȫ����CNC���൱�ڵ�һ���е�CNC��
#define ONE     1
#define TWO     2

int global_time;
default_random_engine e(0);         // ��������Ϊ0
map<int, vector<int>> broken_info;  // �洢������Ϣ
int mes[3];         // �ȴ�rgv�����cnc�ĸ�����Ҳ����ǰrgv�յ�����Ϣ����mes1��2��Ӧ����CNC
struct CNC{
    int id;         // ���{1,2,3,4,5,6,7,8}
    int type;       // �ͺ�{0,1,2}
    int pos;        // λ��{1,2,3,4}
    int state;      // ״̬{0��1���ȴ�cnc, 2���ӹ���, 3��������, 4����Ҫ��}������0��ʾcnc��û�а�
    int time;       // �������0��1״̬�����ʾ�Ѿ��ȴ��˵�ʱ�䣬�������2����ʾ����ӹ���������ʱ��
    int num;        // �ӹ����ϵı��
    int proc_time;  // �ӹ���������ʱ��

    // ���캯��
    CNC(int i, int pt, int ty) : id(i), type(ty), pos((i+1)/2), state(WAIT0), time(0), num(0), proc_time(pt) {}
    CNC(int i, int pt) : id(i), type(0), pos((i+1)/2), state(WAIT0), time(0), num(0), proc_time(pt) {}
    CNC() : CNC(0, 560) {}      // ί�й��캯��

    // ģ��cnc����t�루�ӹ����ߵȴ���������
    // ���룺t  ��ʾ�����ʱ��
    // ���أ�int ������ɺ��״̬
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
                broken_info[num].push_back(global_time + time);     // �����޺õ�ʱ��
                state = WAIT0;      // ������ɺ�CNC������û�����ϵ�
                num = 0;
                time = -time;
                mes[type]++;
            }
        }
        else if(state == BROKEN){
            time -= t;
            if(time <= 0){
                vector<int> bt(1, id);                  // �������ϻ�����Ӧ��CNC���
                bt.push_back(global_time + time);       // ���Ͽ�ʼ��ʱ��
                broken_info[num] = bt;
                state = REPAIR;         // ����ʱ�����10���ӵ�20����֮��
                uniform_int_distribution<int> u(600, 1200);  // ʹ�þ��ȷֲ��Ƿ��ף�
                time = u(e) + time;     // ��Ϊ��ʱtime�Ѿ�С��0��
            }
        }
        return state;
    }

    // ģ��״̬�ı䣬����������
    // ���룺n     �·��ϵ����ϵı��
    // ���أ�int   ������ɺ��״̬
    int change(int n)
    {
        uniform_int_distribution<int> u(0, 100 * proc_time - 1);
        int broken_time = u(e);     // ָ���ж೤ʱ����𻵣�������Ϊ�������������Χ��0~100*proc_time�����Ը�����0.01
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
    int time;           // �ӿ�ʼ���е���ǰ��ʱ��
    int pos;            // λ��{1,2,3,4}
    int n1, n2, n3;     // n1����, n2��ϴ���д�ŵ����ϱ�� {0,1,2,...}������0��ʾû������, n3��ʾ�����ϣ�ֻ�����˹���1��
    int move_time[4] = {0, 20, 33, 46};     // Ĭ���ǵ�һ�������
    int change_time[10] = {0, 28, 31, 28, 31, 28, 31, 28, 31, 0};
    const int clean_time = 25;

    // ���캯��
    RGV(int *a, int *b, int cl) : time(0), pos(1), n1(0), n2(0), n3(0), clean_time(cl)
    {
        for(int i=0;i<4;i++)
            move_time[i] = a[i];
        for(int i=0;i<10;i++)
            change_time[i] = b[i];
    }
    RGV() : time(0), pos(1), n1(0), n2(0), n3(0) {}

    // changeģ��rgv�ӵ�ǰλ��ȥ��n��cnc�����������������һϵ�й���
    // ���룺n  ��ʾ�������cnc���
    // ���أ�int  ��һ���̵�ʱ��
    int change(int n)
    {
        n1++;           //����һ���µ�����
        int total_time = change_time[n];
        time += total_time;
        global_time = time;
        return total_time;
    }

    // move_toģ��rgv�ƶ�
    // ���룺n  ��ʾ�������cnc���
    // ���أ�int ��һ���̵�ʱ��
    int move_to(int n)
    {
        int t = move_time[abs((n+1)/2 - pos)];
        time += t;
        pos = abs((n+1)/2);
        global_time = time;
        return t;
    }


    // cleanģ��rgv��ϴ����
    // ����:num ��ʱ��е���ϵ����ϱ��
    // ���أ���ϴ��������ϴ��ʹ������ϵı��
    int clean(int num)
    {
        int finish = n2;
        n2 = num;
        time += clean_time;
        global_time = time;
        return finish;
    }

    // waitģ��rgvԭ�صȴ�
    // ���룺t   �ȴ���ʱ��
    // ���أ�int �ȴ���ʱ��
    int wait(int t)
    {
        time += t;
        global_time = time;
        return time;
    }
} *rgv_ptr;

// ����
struct matter{
    int cnc_number = -1;
    int start_time = -1;
    int leave_cnc = -1;
    int cnc_number2 = -1;
    int start_time2 = -1;   // �ڶ�������ʼ���뿪ʱ��ʱ��
    int leave_cnc2 = -1;
    int finish_time = -1;
    int is_broken = -1;     // -1��ʾû�б��ϣ�0��ʾ������
} mt[1000];

int find_cnc(vector<CNC>, int p, int ty);

int problem3_1(RGV &rgv, vector<CNC> &cnc, const string file_name)
{
    memset(mt, -1, sizeof(mt));         // ����-1�ǶԵģ���-2�����������ܲ����ˣ���Ϊ��λ��char
    broken_info.clear();
    global_time = 0;
    ofstream out(file_name);
    ofstream out2(file_name.substr(0, file_name.find('.')) + "_broken_info.txt");
    mes[0] = 8;
    while(rgv.time <= 28800){
        if(mes[0]){                        // ��cnc���ڵȴ�״̬
            int n = find_cnc(cnc, rgv.pos, ALL);
            int t = rgv.move_to(n);
            for(int i=1;i<=8;i++)
                cnc[i].proc(t);
            if(!(n%2) && cnc[n-1].state < 2)
                n--;        // ����������﷢�֣����ż���Ż�������Ļ���Ҳ���ˣ��Ǿ��ȴ��������ŵ�
            mt[rgv.n1 + 1].start_time = rgv.time;   // ����rgv.n1+1��ʾ��������������ȥ���µ����ϵı��
            mt[rgv.n1 + 1].cnc_number = n;
            int down = cnc[n].num;      // ȡ�µ�����
            mt[down].leave_cnc = rgv.time;
            t = rgv.change(n);
            for(int i=1;i<=8;i++)
                cnc[i].proc(t);
            cnc[n].change(rgv.n1);
            if(down){                   // ���down��Ϊ0��˵��ȡ�������ϣ�Ҫ��ϴ
                int finish = rgv.clean(down);
                for(int i=1;i<=8;i++)
                    cnc[i].proc(rgv.clean_time);
                mt[finish].finish_time = rgv.time;
                if(finish){             // ���finish��Ϊ0��˵������ϴ����ȡ���˳���
//                    printf("%d finish at %d s\n", finish, rgv.time);
//                    cout << finish << " " << rgv.time << endl;
                }
            }
        }
        else{                           //����cnc���ڼӹ���û�еȴ���cnc
            int min_t = 600;            //�������ҵ�����ĸ�cnc�ܼӹ��ã���Ϊ��󲻿��ܳ���600������������Ϊ600
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
            if(mes[TWO]){                        // �еڶ��������cnc���ڵȴ�״̬
                int n = find_cnc(cnc, rgv.pos, TWO);
                int t = rgv.move_to(n);
                for(int i=1;i<=8;i++)
                    cnc[i].proc(t);
                if(!(n%2) && cnc[n-1].type == TWO && cnc[n-1].state < 2)
                    n--;        // ����������﷢�֣����ż���Ż�������Ļ���Ҳ���ˣ��Ǿ��ȴ��������ŵ�
                mt[rgv.n3].start_time2 = rgv.time;   // ����rgv.n3��ʾ�����ϵı��
                mt[rgv.n3].cnc_number2 = n;
                int down = cnc[n].num;      // ȡ�µ�����
                mt[down].leave_cnc2 = rgv.time;
                t = rgv.change(n);
                rgv.n1--;
                for(int i=1;i<=8;i++)
                    cnc[i].proc(t);
                cnc[n].change(rgv.n3);
                if(down){                   // ���down��Ϊ0��˵��ȡ�������ϣ�Ҫ��ϴ
                    int finish = rgv.clean(down);
                    for(int i=1;i<=8;i++)
                        cnc[i].proc(rgv.clean_time);
                    mt[finish].finish_time = rgv.time;
                    if(finish){             // ���finish��Ϊ0��˵������ϴ����ȡ���˳���
//                        printf("%d finish at %d s\n", finish, rgv.time);
//                        cout << finish << " " << rgv.time << endl;
                    }
                }
                rgv.n3 = 0;         // ������û��ϴ������rgv���϶�û�����ˣ�����˵ֻ�����ϣ���������һ��cnc��
            }
            else{                           //���ж���cnc���ڼӹ���û�еȴ���cnc
                int min_t = 600;            //�������ҵ�����ĸ�����cnc�ܼӹ��ã���Ϊ��󲻿��ܳ���600������������Ϊ600
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
                    n--;        // ����������﷢�֣����ż���Ż�������Ļ���Ҳ���ˣ��Ǿ��ȴ��������ŵ�
                mt[rgv.n1 + 1].start_time = rgv.time;
                mt[rgv.n1 + 1].cnc_number = n;
                int down = cnc[n].num;      // ȡ�µ�����
                mt[down].leave_cnc = rgv.time;
                t = rgv.change(n);
                for(int i=1;i<=8;i++)
                    cnc[i].proc(t);
                cnc[n].change(rgv.n1);
                rgv.n3 = down;              //��ʼȥ�Ҷ���cnc
            }
            else{                           //����һ��cnc���ڼӹ���û�еȴ���cnc
                int min_t = 600;            //�������ҵ�����ĸ�һ��cnc�ܼӹ��ã���Ϊ��󲻿��ܳ���600������������Ϊ600
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

// �������8��cnc��ɵ�vector�� rgv��λ��p���Լ�ҪѰ�ҵ�cnc������ty
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
    problem3_1(rgv1, cnc, "output3-1-1.txt");           // ���������һ�������һ��
    printf("Finish output3-1\n");
    for(int i=1;i<=8;i++){
        CNC t(i, proc_time[1][0]);
        cnc[i] = t;
    }
    problem3_1(rgv2, cnc, "output3-1-2.txt");           // ���������һ������ڶ���
    printf("Finish output3-2\n");
    for(int i=1;i<=8;i++){
        CNC t(i, proc_time[2][0]);
        cnc[i] = t;
    }
    problem3_1(rgv3, cnc, "output3-1-3.txt");           // ���������һ�����������
    printf("Finish output3-3\n");

    // ������������������һ��
    for(unsigned j=0;j<8;j++){
        CNC t(j+1, proc_time[0][(86>>j)%2 + 1], (86>>j)%2 + 1);
        cnc[j+1] = t;
    }
    problem3_2(rgv1, cnc, "output3-2-1.txt");
    printf("Finish output3-2-1\n");

    // �����������������ڶ���
    for(unsigned j=0;j<8;j++){
        CNC t(j+1, proc_time[1][(85>>j)%2 + 1], (85>>j)%2 + 1);
        cnc[j+1] = t;
    }
    problem3_2(rgv2, cnc, "output3-2-2.txt");
    printf("Finish output3-2-2\n");

    // �����������������ڶ���
    for(unsigned j=0;j<8;j++){
        CNC t(j+1, proc_time[2][(81>>j)%2 + 1], (81>>j)%2 + 1);
        cnc[j+1] = t;
    }
    problem3_2(rgv3, cnc, "output3-2-3.txt");
    printf("Finish output3-2-3\n");

    return 0;
}
