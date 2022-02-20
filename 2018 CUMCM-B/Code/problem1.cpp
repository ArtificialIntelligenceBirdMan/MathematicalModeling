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

int mes;        // �ȴ�rgv�����cnc�ĸ�����Ҳ����ǰrgv�յ�����Ϣ��
struct CNC{
    int id;     // ���{1,2,3,4,5,6,7,8}
    int pos;    // λ��{1,2,3,4}
    int state;  // ״̬{0��1���ȴ�cnc, 2���ӹ���, 3��������}������0��ʾcnc��û�а�
    int time;   // �������0��1״̬�����ʾ�Ѿ��ȴ��˵�ʱ�䣬�������2����ʾ����ӹ���������ʱ��
    int num;    // �ӹ����ϵı��
    int proc_time = 560;  // �ӹ���������ʱ��

    // ���캯��
    CNC(int i, int pt) : id(i), pos((i+1)/2), state(WAIT0), time(0), num(0), proc_time(pt)  {}
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
                mes++;
            }
        }
        return state;
    }

    // ģ��״̬�ı䣬����������
    // ���룺n     �·��ϵ����ϵı��
    // ���أ�int   ������ɺ��״̬
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
    int time;           // �ӿ�ʼ���е���ǰ��ʱ��
    int pos;            // λ��{1,2,3,4}
    int n1, n2;         // n2��ϴ���д�ŵ����ϱ�� {0,1,2,...}������0��ʾû������, n1����
    int move_time[4] = {0, 20, 33, 46};
    int change_time[10] = {0, 28, 31, 28, 31, 28, 31, 28, 31, 0};
    const int clean_time = 25;

    // ���캯��
    RGV(int *a, int *b, int cl) : time(0), pos(1), n1(0), n2(0), clean_time(cl)
    {
        for(int i=0;i<4;i++)
            move_time[i] = a[i];
        for(int i=0;i<10;i++)
            change_time[i] = b[i];
    }
    RGV() : time(0), pos(1), n1(0), n2(0) {}

    // changeģ��rgv�ӵ�ǰλ��ȥ��n��cnc�����������������һϵ�й���
    // ���룺n  ��ʾ�������cnc���
    // ���أ�int  ��һ���̵�ʱ��
    int change(int n)
    {
        n1++;           //����һ���µ�����
        int total_time = change_time[n];
        time += total_time;
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
        return finish;
    }
};

// ����
struct matter{
    int cnc_number = -1;
    int start_time = -1;
    int leave_cnc = -1;
    int finish_time = -1;
} mt[1000];

int find_cnc(vector<CNC>, int p);

int problem1(RGV &rgv, vector<CNC> &cnc, const string file_name)
{
    memset(mt, -1, sizeof(mt));         // ����-1�ǶԵģ���-2�����������ܲ����ˣ���Ϊ��λ��char
    ofstream out(file_name);
    mes = 8;
    while(rgv.time <= 28800){
        if(mes){                        // ��cnc���ڵȴ�״̬
            int n = find_cnc(cnc, rgv.pos);
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
                    printf("%d finish at %d s\n", finish, rgv.time);
                    cout << finish << " " << rgv.time << endl;
                }
            }
        }
        else{                           //����cnc���ڼӹ���û�еȴ���cnc
            int min_t = 600;            //�������ҵ�����ĸ�cnc�ܼӹ��ã���Ϊ��󲻿��ܳ���600������������Ϊ600
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
    problem1(rgv1, cnc, "output1-1.txt");           // �����һ�ʵ�һ��

    RGV rgv2(move_time[1], change_time[1], clean_time[1]);
    for(int i=1;i<=8;i++){
        CNC t(i, 580);
        cnc[i] = t;
    }
    problem1(rgv2, cnc, "output1-2.txt");           // �����һ�ʵڶ���

    RGV rgv3(move_time[2], change_time[2], clean_time[2]);
    for(int i=1;i<=8;i++){
        CNC t(i, 545);
        cnc[i] = t;
    }
    problem1(rgv3, cnc, "output1-3.txt");           // �����һ�ʵ�����
    return 0;
}
