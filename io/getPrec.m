function [prec nb] = getPrec(h)
switch h.sheader.ftype
    case 'D'
        switch h.sheader.d_val.data_cell_size
            case 2
                prec = 'int16';
                nb = 2;
            case 3
                prec = 'int32';
                nb = 4;
            otherwise
                prec = 'uint8';
                nb = 1;
        end
    case 'R'
        prec = 'float32';
        nb = 4;
    otherwise
        prec = 'uint8';
        nb = 1;
end