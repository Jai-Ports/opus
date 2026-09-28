analysis_compute_dense :: (layer: *Analysis_Dense_Layer, output: *float32, input: *float32) {
    m := layer.nb_inputs;
    n := layer.nb_neurons;
    stride := n;
    if 0 < n {
        for i: 0..n - 1 {
            output[i] = cast,no_check(float32) layer.bias[i];
        }
    }
    gemm_accum(output, layer.input_weights, n, m, stride, input);
    if 0 < n {
        for i: 0..n - 1 {
            output[i] *= 0.0078125;
        }
    }
    if layer.sigmoid != 0 {
        if 0 < n {
            for i: 0..n - 1 {
                output[i] = sigmoid_approx(output[i]);
            }
        }
    } else {
        if 0 < n {
            for i: 0..n - 1 {
                output[i] = tansig_approx(output[i]);
            }
        }
    }
}

tansig_approx :: (x: float32) -> float32 {
    N0: float32 = cast(float32) 952.5280151367188;
    N1: float32 = cast(float32) 96.3923568725586;
    N2: float32 = 0.60863042;
    D0: float32 = cast(float32) 952.7239990234375;
    D1: float32 = cast(float32) 413.3680114746094;
    D2: float32 = cast(float32) 11.886009216308594;
    x2: float32 = ---;
    x2 = x * x;
    num :=
        (((cast(float32) 0.6086304187774658) * x2 + cast(float32) 96.3923568725586) * x2) +
            cast(float32) 952.5280151367188;
    den :=
        (((cast(float32) 11.886009216308594) * x2 + cast(float32) 413.3680114746094) * x2) +
            cast(float32) 952.7239990234375;
    num = num * x / den;
    return ifx c_transpiler_float_greater(-1.0, (ifx c_transpiler_float_less(1.0, num) then 1.0 else num)) then -1.0 else (ifx c_transpiler_float_less(1.0, num) then 1.0 else num);
}

sigmoid_approx :: (x: float32) -> float32 {
    return 0.5 + 0.5 * tansig_approx(0.5 * x);
}

gemm_accum :: (out: *float32, weights: *Int8, rows: s32, cols: s32, col_stride: s32, x: *float32) {
    j: s32 = ---;
    if 0 < rows {
        for i: 0..rows - 1 {
            j = 0;
            while j < cols {
                out[i] += weights[j * col_stride + i] * x[j];
                j += 1;
            }
        }
    }
}

analysis_compute_gru :: (gru: *Analysis_GRU_Layer, state: *float32, input: *float32) {
    tmp: [32] float32 = ---;
    z: [32] float32 = ---;
    r: [32] float32 = ---;
    h: [32] float32 = ---;
    m := gru.nb_inputs;
    n := gru.nb_neurons;
    stride := 3 * n;

    if 0 < n {
        for i: 0..n - 1 {
            z[i] = cast,no_check(float32) gru.bias[i];
        }
    }
    gemm_accum(z.data, gru.input_weights, n, m, stride, input);
    gemm_accum(z.data, gru.recurrent_weights, n, n, stride, state);
    if 0 < n {
        for i: 0..n - 1 {
            z[i] = sigmoid_approx(0.0078125 * z[i]);
        }
    }

    if 0 < n {
        for i: 0..n - 1 {
            r[i] = cast,no_check(float32) gru.bias[n + i];
        }
    }
    gemm_accum(r.data, *gru.input_weights[n], n, m, stride, input);
    gemm_accum(r.data, *gru.recurrent_weights[n], n, n, stride, state);
    if 0 < n {
        for i: 0..n - 1 {
            r[i] = sigmoid_approx(0.0078125 * r[i]);
        }
    }

    if 0 < n {
        for i: 0..n - 1 {
            h[i] = cast,no_check(float32) gru.bias[2 * n + i];
        }
    }
    if 0 < n {
        for i: 0..n - 1 {
            tmp[i] = state[i] * r[i];
        }
    }
    gemm_accum(h.data, *gru.input_weights[2 * n], n, m, stride, input);
    gemm_accum(h.data, *gru.recurrent_weights[2 * n], n, n, stride, tmp.data);
    if 0 < n {
        for i: 0..n - 1 {
            h[i] = z[i] * state[i] + (1.0 - z[i]) * tansig_approx(0.0078125 * h[i]);
        }
    }
    if 0 < n {
        for i: 0..n - 1 {
            state[i] = h[i];
        }
    }
}

