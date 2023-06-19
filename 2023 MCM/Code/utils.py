import pandas as pd
import numpy as np
from matplotlib import pyplot as plt
from sklearn.metrics import confusion_matrix, accuracy_score
import statsmodels.api as sm
from scipy.optimize import curve_fit
from typing import Callable, Any
from scipy.stats import norm
from tqdm import tqdm
from joblib import delayed, Parallel

def breakpoint_detection_regression(data : pd.Series, left : int=0, right : int=None, iters : int=3):
    # find breakpoints by dichotomy
    bp = int(len(data) / 2)
    if right is None:
        right = len(data)
    
    k = 0
    min_mse = np.Inf
    while k < iters:
        # Left hand regression
        y = data[left:bp].values
        x = np.arange(len(y))
        ols = sm.OLS(y,x)
        mse_left = ols.fit().mse_resid

        # right hand regression
        y = data[bp:right].values
        x = np.arange(len(y))
        ols = sm.OLS(y,x)
        mse_right = ols.fit().mse_resid

        # update best bp
        if mse_left + mse_right < min_mse:
            min_mse = mse_left + mse_right
            best_bp = bp

        # update bp
        if mse_left > mse_right:
            bp = (left + bp) // 2 + 1
        else:
            bp = (right + bp) // 2 - 1
        
        k += 1

    return left + best_bp

def curve_fit_estimate(ydata, formula : Callable, alpha : float=0.95, **kwargs):
    xdata = np.arange(1,len(ydata)+1) / 1e2
    # fit parameters
    opt_params, cov_params = curve_fit(formula, xdata, ydata, method="lm",**kwargs)

    # calculate bounds of params
    std = np.sqrt(np.diag(cov_params))
    lower_bound = opt_params - norm.ppf(0.5 + alpha/2) * std
    upper_bound = opt_params + norm.ppf(0.5 + alpha/2) * std

    return opt_params, cov_params, lower_bound, upper_bound

def curve_fit_predict(N : int, formula, opt_params : np.ndarray, 
    cov_params : np.ndarray, directions : list=None, alpha : float=0.95):
    """
    Use fitted curve to make predictions.
    """
    xdata = np.arange(1,N+1) / 100
    # center Forecast
    pred_center = formula(xdata, *opt_params)
    # estimate prediction interval
    std = np.sqrt(np.diag(cov_params))

    if directions is None:
        directions = [True for i in range(len(opt_params))]
    lower_sign, upper_sign = [], []
    for i in range(len(opt_params)):
        if directions[i]:
            lower_sign.append(-1)
            upper_sign.append(1)
        else:
            lower_sign.append(1)
            upper_sign.append(-11)
    lower_sign, upper_sign = np.array(lower_sign), np.array(upper_sign)

    # calculate bounds of params
    lower_bound = opt_params + lower_sign*norm.ppf(0.5 + alpha/2) * std
    upper_bound = opt_params + upper_sign*norm.ppf(0.5 + alpha/2) * std

    lower_pred = formula(xdata,*lower_bound)
    upper_pred = formula(xdata, *upper_bound)

    pred = pd.DataFrame()
    pred["lower"] = lower_pred
    pred["center"] = pred_center
    pred["upper"] = upper_pred

    return pred

# check Wordle targer word
def check_target(guess : str, target : str) -> str:
    """
    Return
    ----------
    score : str
        return a 5 number code.\n 
        `1` represents there is no matched letter.\n
        `2` represents there is a matched letter but in wrong position.\n
        `3` represents there is a matched letter and in right position.\n
    """
    score = ["1", "1", "1", "1", "1"]
    pos = set([0, 1, 2, 3, 4])
    for i in range(5):
        if guess[i] == target[i]:
            score[i] = "3"
            pos.remove(i)
    remains = [target[i] for i in pos]
    for i in pos:
        if guess[i] in remains:
            score[i] = "2"
            remains.remove(guess[i])
    return "".join(score)

def create_wordle_score_table(valid_words : pd.Series, ans_words : pd.Series, n_jobs : int=16):
    """
    Parameters
    ----------
    valid_words : pd.Series
        The set of valid words.
    ans_words : pd.Series
        The set of answer words.
    """
    # parallel acceleration
    def helper_func(valid_words, ans_words_subset):
        table = pd.DataFrame(index=ans_words_subset,columns=valid_words)
        for target in tqdm(ans_words_subset):
            for guess in valid_words:
                table.loc[target,guess] = check_target(guess,target)
        return table
    
    # create params list
    n_sub = int(len(ans_words) / n_jobs) + 1
    params_list = []
    for i in range(n_jobs):
        params = {
            "valid_words": valid_words.copy(),
            "ans_words_subset": ans_words[n_sub*i:n_sub*(i+1)]
        }
        params_list.append(params)
    
    tables = multi_task(helper_func,params_list,n_jobs,verbose=1)
    table = pd.concat(tables,axis=0)
    
    return table

# calculate gain
def build_gain_recur(target : str, pivot_score : pd.DataFrame, valid_words_freq : pd.Series, 
                     feasible_set : pd.Index=None, rounds : int=1, deep : int=1, verbose : bool=False):
    """
    Parameters
    ----------
    target : str
        The target word to be guessed.
    pivot_score : pd.DataFrame
        The pivot table of Wrodle score.
    valid_words_freq : pd.Series
        The valid words set and it's word frequency.
    rounds : int, default = 1
        The considered rounds for calculate gain.
    verbose : bool, default = `False`
        Whether to show progress.
    """
    # The first round of search is conducted on all valid words
    # Subsequent rounds of search are only conducted in the answer space
    if feasible_set is None:
        feasible_set = valid_words_freq.index
    N = len(pivot_score) if deep == 1 else len(feasible_set)

    gain = []
    for i,guess in enumerate(feasible_set):
        # find Wordle score of guess
        score = pivot_score.loc[target,guess]
        # fetch all possible collections of word
        next_feasible_set = pivot_score.index[pivot_score.loc[:,guess] == score]
        N1 = len(next_feasible_set)
        if rounds > 1 and len(next_feasible_set) > 0:
            gain.append(np.log2(N) - np.log2(N1) + build_gain_recur(
                target,pivot_score,valid_words_freq.copy(),next_feasible_set,rounds-1,deep+1)[1])
        else:
            gain.append(np.log2(N) - np.log2(N1))
        if deep == 1 and verbose:
            print('Progress {:.4f}%'.format((i+1) / len(feasible_set)),end="\r",flush=True)
    gain = pd.Series(index=feasible_set,data=gain)

    # add weights
    valid_words_freq = valid_words_freq[feasible_set]
    valid_words_freq = valid_words_freq / valid_words_freq.sum() # rescale weight
    gain = (gain * valid_words_freq).sum()
    
    return [target, gain]

def build_gain_parallel(words : list, pivot_score : pd.DataFrame, 
                        valid_words_freq : pd.Series, rounds : int, n_jobs : int=20):
    """
    The parallel acceleration for `build_gain_recur()`

    Parameters
    ----------
    words : list of str
        The list of target word.
    pivot_score : pd.DataFrame
        The pivot table of Wrodle score.
    valid_words_freq : pd.Series
        The valid words set and it's word frequency.
    rounds : int, default = 1
        The considered rounds for calculate gain.
    n_jobs : int, default = 20
        The parallel jobs.
    """
    # create params list
    params_list = []
    for word in words:
        params = {
            "target": word,
            "pivot_score": pivot_score,
            "valid_words_freq": valid_words_freq.copy(),
            "rounds": rounds
        }
        params_list.append(params)

    gains = multi_task(build_gain_recur,params_list,n_jobs,verbose=1)
    words = [gain[0] for gain in gains]
    gains = [gain[1] for gain in gains]
    gains = pd.Series(index=words,data=gains)

    return gains

def multi_task(func : Callable, param_list : list, n_job : int=-1, verbose : int=1) -> list:
    """
    multi_task(func : Callable, param_list : list, n_job : int=-1, verbose : int=1) -> list
        The multi process auxiliary function.\n 
        Pass in a function `func` and its required parameter list `param_List`,\n 
        using multi process acceleration to get calculation results.\n
    
    Parameters
    ----------
    func : Callable
        Callable object that performs the calculation.
    param_list : list of dict
        List of parameters required for `func` calculation.\n
        If multiple parameters need to be passed in, List of dict is recommended, \n
        each dict represents the parameter passed to func when a process is running.\n 
        Dict consists of the signature of the parameter and the value to be used to form a `key: value` pair.
    n_job : int, default = `1`
        Number of multiple processes.\n 
        For details, see the parameter description of joblib.Parallel
    verbose : int, default = `1`
        Tracking level of multi process progress.\n
        For details, see the parameter description of joblib.Parallel.
    
    Return
    ----------
    result : list
        Under each group of parameters, the calculation results of each process \n
        will be saved in a list and returned.
    
    How to use
    ----------
    Suppose the Callable object `func` to be calculated has the following calling forms: \n

      >>> result = func(param1, param2, param3, ...)
    
    In order to track the output for different parameters with the results of multi process auxiliary functions, 
    the following auxiliary function `func_helper` can be constructed: \n
      
      >>> def func_helper(param1, param2, param3, ...):
      >>>     res = {
      >>>         "param1": param1, 
      >>>         "param2": param2, 
      >>>         "param3": param3, 
      >>>         ..., # record other parameters
      >>>         "result": func(param1, param2, param3, ...) # save the calculation results
      >>>     }
      >>>     # return the dict for saved parameters and calculation results
      >>>     return res 

    The input of `func_helper` can only be set to the parameters that need to be adjusted and tested, 
    which can reduce the number of fixed parameters to be passed to `func`. \n

    Then, create a parameter list `param_list` to be passed to `func`(i.e. `func_helper`), 
    and then call `multi_task` to get the calculation results.

      >>> result = multi_task(func_help, param_list, n_job=4, verbose=1)
    
    Examples
    ----------
    Here is an example of multiplying two numbers: \n

      >>> def multiplication(a, b):
      >>>     return a * b
      >>> def mutiplication_helper(a, b): # auxiliary function for tracking parameters
      >>>     res = {
      >>>         "a": a, # track the first parameter
      >>>         "b": b, # track the second parameter
      >>>         "res": multiplication(a, b) # save result
      >>>     }
      >>>     return res
      >>> # create a parameter list, which consists of a dictionary with parameter signature
      >>> param_list = [{"a": a, "b": b} for a in range(2) for b in range(2)]
      >>> # call the multi process auxiliary function to get the calculation results
      >>> res = multi_task(mutiplication_helper, param_list, n_job = 4, verbose = 1)

    Print the calculation results. \n
    The output of the multi process auxiliary function is a list composed of dictionaries. \n
    Each dictionary stores the parameters used in the calculation and the calculation results.\n

      >>> for r in res:
      >>>     print("Param1: %s, Param2: %s, Result: %s"%(r["a"], r["b"], r["res"]))
      Param1: 0, Param2: 0, Result: 0
      Param1: 0, Param2: 1, Result: 0
      Param1: 1, Param2: 0, Result: 0
      Param1: 1, Param2: 1, Result: 1
    
    The results of multi process calculation can be used for subsequent analysis, such as finding the optimal parameters.
    """
    return Parallel(n_jobs=n_job, verbose=verbose)(delayed(func)(**param) for param in param_list)

def plot_confusion_matrix(y_true, y_pred, labels):
    """
    plot_confusion_matrix(y_true, y_pred)
        绘制混淆矩阵
        
    Parameters
    ----------
    y_true : np.ndarray
        数据的真实标签
    y_pred : np.ndarray
        模型的预测结果
    labels : list
        各个类别的含义
    """
    import itertools

    acc = accuracy_score(y_true, y_pred)
    mat = confusion_matrix(y_true, y_pred)
    print("accuracy: %.4f"%(acc))
    
    # 绘制混淆矩阵
    fig = plt.figure(figsize=(3,3),dpi=100)
    plt.imshow(mat,cmap=plt.cm.Blues)
    
    thresh = mat.max() / 2
    for i, j in itertools.product(range(mat.shape[0]), range(mat.shape[1])):
        # 在每个位置添加上样本量
        plt.text(j, i, mat[i, j],
                 horizontalalignment="center",
                 color="white" if mat[i, j] > thresh else "black")
    plt.tight_layout()
    plt.xticks(range(mat.shape[0]),labels)
    plt.yticks(range(mat.shape[0]),labels)
    plt.ylabel('True label')
    plt.xlabel('Predicted label')