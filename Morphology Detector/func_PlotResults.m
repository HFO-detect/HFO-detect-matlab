function func_PlotResults( results, fs)

LimitRaw = 300;
LimitRip = 50;
LimitFR  = 25;
LimitXaxe = [0 300];

%% Plot
t = 1/fs:1/fs:length(results.signal)/fs;

%% RAW DATA
ax(1) = subplot(311);
plot(t,results.signal)
ylim([-LimitRaw LimitRaw])
xlim(LimitXaxe)
hold on
func_PlotDetectedEvents( results, results.signal,  t, 1, fs )
title('Raw signal')

%% RIPPLE DATA
ax(2) = subplot(312);
plot(t,results.signalFilt)
ylim([-LimitRip LimitRip])
xlim(LimitXaxe)
hold on
func_PlotDetectedEvents( results, results.signalFilt,  t, 2, fs )
title('Ripple range')

%% FR DATA
ax(3) = subplot(313);
plot(t,results.signalFiltFR)
ylim([-LimitFR LimitFR])
xlim(LimitXaxe)
hold on
func_PlotDetectedEvents( results, results.signalFiltFR,  t, 3, fs )
title('Fast Ripple range')

% link all subplots
linkaxes(ax, 'x');

end % func_PlotResults

% Function to Mark detected events on a plot
function func_PlotDetectedEvents( StructWithDetections, sig,  t_axis, PlotSignal, fs )

switch PlotSignal
    case 1 % all ripple and FRs
        % first Rip
        for i=1:length(StructWithDetections.autoRipSta)
            inds = floor(StructWithDetections.autoRipSta(i)*fs:StructWithDetections.autoRipEnd(i)*fs);
            plot(t_axis(inds),sig(inds),'r')
        end
        % second FR
        for i=1:length(StructWithDetections.autoFRSta)
            inds = floor(StructWithDetections.autoFRSta(i)*fs:StructWithDetections.autoFREnd(i)*fs);
            plot(t_axis(inds),sig(inds),'r')
        end
    case 2 % ripple
        for i=1:length(StructWithDetections.autoRipSta)
            inds = floor(StructWithDetections.autoRipSta(i)*fs:StructWithDetections.autoRipEnd(i)*fs);
            plot(t_axis(inds),sig(inds),'r')
        end
    case 3 % FR
        for i=1:length(StructWithDetections.autoFRSta)
            inds = floor(StructWithDetections.autoFRSta(i)*fs:StructWithDetections.autoFREnd(i)*fs);
            plot(t_axis(inds),sig(inds),'r')
        end
end

end % func_PlotDetectedEvents
