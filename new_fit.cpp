#include "mex.h"
//#include "fit.h"
#include <stdio.h>
#include <string.h>
#include <math.h>

#define MIN(a,b) (((a)<(b))?(a):(b))
#define MAX(a,b) (((a)>(b))?(a):(b))

#define PI 3.14159265358979323846

const int Max_Num = 20;
// Number of time stpes
//const int Steps = 30;
// Initial range
//const double Init_box = 4;
//const double InitVmin = 0.25;
//const double InitVmax = 0.75;

// Minimum distance for collision freedom
//const double Dmin = 1;

const int Ph = 2;
// wing span
const double w = 1;
// y_opt for upwash
const double d0 = 1;
// x_opt is 2w-lambda 
const double lambda = 0.5 - PI / 8;
// angle of clear view cone
const double angle = PI / 6;

// Gaussian params for upwash
const double u_sigma1 = 5;
const double u_sigma2 = 5;
const double d_sigma1 = 1 / 0.3;
const double d_sigma2 = 1 / 0.7;

// bound on acceleration w.r.t velocity
const double delta = 1;

static inline double norm(double x, double y) {
	return sqrt(x * x + y * y);
}

static inline double mvnpdf(double x, double y, double a, double b) {
	return exp(-0.5 * (a * x * x + b * y * y));
}

static inline double dot(double x1, double y1, double x2, double y2) {
    return x1*x2 + y1*y2;
}

double v_matching(double *vx, double *vy, int num) {
	double sum = 0.0f;
	for (int i = 0; i < num; i++) {
		for (int j = i + 1; j < num; j++) {
			double diff = norm(vx[i] - vx[j], vy[i] - vy[j])
					/ (norm(vx[i], vy[i]) + norm(vx[j], vy[j]));
			sum += diff * diff;
		}
	}
	return sum;
}

double flock_fit(double *va, double *cx, double *cy, double *cvx, double *cvy, int *ph, const int Num) {
	//flock_info *info = (flock_info *) params;
	double nextX[Max_Num], nextY[Max_Num], nextVX[Max_Num], nextVY[Max_Num];
    /*
    double *nextX, *nextY, *nextVX, *nextVY;
    nextX = (double *)malloc(sizeof(double) * Num);
    nextY = (double *)malloc(sizeof(double) * Num);
    nextVX = (double *)malloc(sizeof(double) * Num);
    nextVY = (double *)malloc(sizeof(double) * Num);
     **/
    
	for (int i = 0; i < Num; i++) {
		nextVX[i] = cvx[i] + va[i] * cos(va[i + Num]);
		nextVY[i] = cvy[i] + va[i] * sin(va[i + Num]);
        nextX[i] = cx[i] + nextVX[i] * *ph;
        nextY[i] = cy[i] + nextVY[i] * *ph;
/* 		newVX[i] = nextVX[i] + va[i+Num] * cos(va[i + (Ph + 1) * Num]);
		newVY[i] = nextVY[i] + va[i+Num] * sin(va[i + (Ph + 1) * Num]);
		newX[i] = info->cx[i] + newVX[i] + nextVX[i];
		newY[i] = info->cy[i] + newVY[i] + nextVY[i]; */
		//printf("%f\t%f\t%f\t%f\n", newX[i], newY[i], newVX[i], newVY[i]);
	}
    double fitness=0;
    
	double obstacle = 0, benefit = 0, ca = 0;
	double blocks[Max_Num][2];
    /*
    double *blocks[2];
    blocks[0] = (double *)malloc(sizeof(double) * Num);
    blocks[1] = (double *)malloc(sizeof(double) * Num);
     */
    
	double px = 0, py = 0, k = 0, A = 0, B = 0, C = 0, side = 0, h_dis = 0,
			v_dis = 0, sm = 0, dot_prod = 0, ub_j = 0, angles = 0,
            max_obs2 = 0, min_obs1 = PI / 2 - angle;
			
	for (int i = 0; i < Num; i++) {
		memset(blocks, 0, sizeof(double) * Num * 2);
		A = nextVX[i];
		B = nextVY[i];
		C = -nextVY[i] * nextY[i] - nextVX[i] * nextX[i];
        ub_j = 0; angles = 0;
        max_obs2 = PI / 2 - angle; min_obs1 = PI / 2 + angle;
		for (int j = 0; j < Num; j++) {
			if (j != i) {
               /*  if (cpa(info->cx[i], info->cy[i], info->cx[j], info->cy[j], 
                        nextVX[i], nextVY[i], nextVX[j], nextVY[j]) < Dmin) {
                    ca = INFINITY;
                    break;
                } */
				if (nextVX[i] == 0) {
					px = nextX[j];
					py = nextY[i];
				} else if (nextVY[i] == 0) {
					px = nextX[i];
					py = nextY[j];
				} else {
					k = -nextVX[i] / nextVY[i];
					px = (k * nextX[i] + nextX[j] / k + nextY[j] - nextY[i])
							/ (k + 1 / k);
					py = -1 / k * (px - nextX[j]) + nextY[j];
				}

				side = A * nextX[j] + B * nextY[j] + C;
//                 printf("side: %f", side);
				h_dis = norm(px - nextX[i], py - nextY[i]);
				v_dis = fabs(side) / norm(A, B);

				if (side >= 0
						&& (h_dis < w || (h_dis - w) / v_dis < tan(angle))) {
					blocks[j][0] = atan(v_dis / (h_dis + w));
					blocks[j][1] = atan2(v_dis, h_dis - w);
					if (blocks[j][0] < PI / 2 - angle)
						blocks[j][0] = PI / 2 - angle;
					if (blocks[j][1] > PI / 2 + angle)
						blocks[j][1] = PI / 2 + angle;
// 					obstacle += (blocks[j][1] - blocks[j][0]) / (angle);
                    max_obs2 = MAX(blocks[j][1],max_obs2);
                    min_obs1 = MIN(blocks[j][0],min_obs1);
				}
				
				sm = erf((h_dis - (w - lambda)) * sqrt(2.0) * 8.0);
//                 printf("sm: %f", sm);
				dot_prod = (nextVX[i] * nextVX[j] + nextVY[i] * nextVY[j])
						/ (norm(nextVX[i], nextVY[i]) * norm(nextVX[j], nextVY[j]));
				if (side > 0 && h_dis >= w - lambda)
					ub_j += dot_prod * sm
							* mvnpdf(h_dis - (2 * w - lambda), v_dis - d0,
									u_sigma1, u_sigma2);
				else if (side < 0 && h_dis < w - lambda)
					ub_j += sm * mvnpdf(h_dis, v_dis, d_sigma1, d_sigma2);
//                 printf("ub_j: %f", ub_j);
			}
		}
        benefit += MIN(ub_j,1);
        angles = MAX(max_obs2-min_obs1,0);
        obstacle += angles / angle;
//         printf("angles: %f", angles);
//         printf("obstacle: %f", obstacle);
//         printf("benefit: %f", benefit);
	}
    fitness = pow(v_matching(nextVX, nextVY, Num),2) + pow(obstacle,2) + pow(Num - 1 - benefit,2);// + ca;
    
    /*free(nextX);
    free(nextY);
    free(nextVX);
    free(nextVY);
    free(blocks[0]);
    free(blocks[1]);*/
    
    return fitness;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) { 

/* get the value of the scalar input  */
double *va = mxGetPr(prhs[0]);
double *x  = mxGetPr(prhs[1]);
double *y  = mxGetPr(prhs[2]);
double *vx = mxGetPr(prhs[3]);
double *vy = mxGetPr(prhs[4]);
int ph = mxGetScalar(prhs[5]);
int Num = mxGetScalar(prhs[6]);

//double flock_fit(double *va, double *cx, double *cy, double *cvx, double *cvy, int *ph);
double fitness = flock_fit(va, x, y, vx, vy, &ph, Num);
plhs[0] = mxCreateDoubleScalar(fitness);

return; 

}
