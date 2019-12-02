function Hungarian()
    clc();
    MAXIMIZATION = false;

    fprintf('\n\n\n\n\n---------------------------\n\n');

    %% Step 1
    C_initial = initialMatrix();

    dispC(C_initial, 'Given matrix C');

    if MAXIMIZATION
        C = maximize(C_initial);
        dispC(C, 'Maximization task C')
    else
        C = C_initial;
    end
    
    %% Step 2
    C = subColumnMin(C);
    dispC(C, 'After subtraction columns');

    %% Step 3
    C = subRowMin(C);
    dispC(C, 'After subtraction rows');

    while C.numbOfPlus < C.sizeMatrix
	    %% Step 4.1
	    C = markStarZeros(C);
	    dispC(C, 'Marked *');

	    %% Step 4.2
	    C = markPlusZeros(C);
	    dispC(C, 'Marked +');

	    %% Step 5.2
	    if C.numbOfPlus == C.sizeMatrix
	    	C = unMark(C);
	    	dispC(C, 'Unmarked');
	    	break;
	    end

	    C.numbOfPlus = 0;

	    %% Step 5.1
	    [C, minNumber] = findMinAndCal(C);
	    fprintf('Mininum number: %2d \n', minNumber);
	    dispC(C, 'Calculate');

	    %% Step 5.2
	    C = unMark(C);
	    dispC(C, 'Unmarked');
	end

	C = optimizedMatrix(C);
	dispC(C, 'X(optimized):');

	fopt = calcF(C_initial, C.matrix);

	fprintf('F(X_optimized):\n');
    disp(fopt);
end


%%-----------------------------------------------------------------------------
%% Setup matrix C
function C = SetupMatrixC(matrix, sizeMatrix, star, markedRows, markedColumns, numbOfPlus)
	C = struct('matrix', matrix, 'sizeMatrix', sizeMatrix, 'star', star, 'markedRows',
		markedRows, 'markedColumns', markedColumns, 'numbOfPlus', numbOfPlus);
end


%%-----------------------------------------------------------------------------
%% Change to type maximization
function result = maximize(C)
    matrix = C.matrix;

	%% matrix(:,:) = max(matrix) - matrix(:,:);
	matrix = -matrix + max(max(matrix));

	result = C;
	result.matrix = matrix;
end


%%-----------------------------------------------------------------------------
%% displaying the current state of matrix C with * and +
function dispC(C, msg)
    matrix = C.matrix;
    sizeMatrix = C.sizeMatrix;

    fprintf('%s:\n', msg);
    for r = 1:sizeMatrix
        for c = 1:sizeMatrix
            fprintf('  %4g', matrix(r,c));
            if C.star(r,c)
                fprintf('*');
            else
                fprintf(' ');
            end
        end

        if C.markedRows(r)
            fprintf('  +\n');
        else
            fprintf('   \n');
        end  
    end

    for c = 1:sizeMatrix
        if C.markedColumns(c)
            p = '+';
        else
            p = ' ';
        end
        fprintf('  %4c ', p);
    end
    fprintf('\n\n');
end


%%-----------------------------------------------------------------------------
%% Step 1: Initial matrix
function C = initialMatrix()
    matrix = [4 2 8 7 5; 4 5 7 8 3; 2 2 1 7 4; 9 5 3 2 9; 5 3 4 6 1];

    % matrix = [4 10 10 3 6; 5 6 2 7 4; 9 5 6 8 3; 2 3 5 4 8; 8 5 4 9 3];

    [rows, cols] = size(matrix);
    assert(rows == cols, 'Matrix should be square!');

    %% This matrix for save data
    tmpMatrix = zeros(rows,cols);

    C = SetupMatrixC(matrix, rows, tmpMatrix, tmpMatrix(:,1), tmpMatrix(1,:), 0);
end


%%-----------------------------------------------------------------------------
%% Step 2: Subtract all columns by minimum value
function result = subColumnMin(C)
	matrix = C.matrix;
	sizeMatrix = C.sizeMatrix;

	for i = 1:sizeMatrix
		col = matrix(:,i);
		matrix(:,i) = col - min(col);
	end

	result = C;
	result.matrix = matrix;
end


%%-----------------------------------------------------------------------------
%% Step 3: Subtract all rows by minimum value
function result = subRowMin(C)
	matrix = C.matrix;
	sizeMatrix = C.sizeMatrix;

	for i = 1:sizeMatrix
		row = matrix(i,:);
		matrix(i,:) = row - min(row);
	end

	result = C;
	result.matrix = matrix;
end


%%-----------------------------------------------------------------------------
%% Step 4.1: Mark 0* in the matrix
function result = markStarZeros(C)
	matrix = C.matrix;
	sizeMatrix = C.sizeMatrix;
	star = C.star;

	for r = 1:sizeMatrix
		for c = 1:sizeMatrix
			if matrix(r,c) == 0
				star(r,c) = true;
			end
		end
	end

	result = C;
	result.star = star;
end


%%-----------------------------------------------------------------------------
%% Step 4.2: Mark columns or rows with plus
function result = markPlusZeros(C)
	matrix = C.matrix;
	sizeMatrix = C.sizeMatrix;
	star = C.star;
	markedRows = C.markedRows;
	markedColumns = C.markedColumns;
	numbOfPlus = C.numbOfPlus;
	count = 0;     %% Number of zeros in a row or a columns
	index = 1;     %% Save location = 0
	countZeros = 0;

	while true
		for r = 1:sizeMatrix
			for c = 1:sizeMatrix
				if star(r,c) == true
					index = c;
					count++;
				end
			end

			if count == 1
				markedColumns(index) = true;
			end

			count = 0;
		end

		for r = 1:sizeMatrix
			for c = 1:sizeMatrix
				if (star(r,c) == true && markedColumns(c) == true)
					star(r,c) = false;
				end
			end
		end

		for c = 1:sizeMatrix
			for r = 1:sizeMatrix
				if star(r,c) == true
					index = r;
					count++;
				end
			end

			if count == 1
				markedRows(index) = true;
			end

			count = 0;
		end

		for r1 = 1:sizeMatrix-1
			for r2 = r1+1:sizeMatrix
				for c = 1:sizeMatrix
					if (markedColumns(c) == false && star(r1,c) == true && star(r2,c) == true)
						markedColumns(c) = true;
					end
				end
			end
		end

		for c = 1:sizeMatrix
			for r = 1:sizeMatrix
				if (star(r,c) == true && markedRows(r) == true)
					star(r,c) = false;
				end
			end
		end

		countZeros = 0;

		for r = 1:sizeMatrix
			for c = 1:sizeMatrix
				if star(r,c) == true
					countZeros++;
				end
			end
		end

		if countZeros == 0
			break;
		end
	end

	for r = 1:sizeMatrix
		if markedRows(r) == true
			numbOfPlus++;
		end
	end

	for c = 1:sizeMatrix
		if markedColumns(c) == true
			numbOfPlus++;
		end
	end

	result = C;
	result.markedRows = markedRows;
	result.markedColumns = markedColumns;
	result.numbOfPlus = numbOfPlus;
end


%%-----------------------------------------------------------------------------
%% Step 5.1: Find min number of matrix don't covered and calculate
function [result, minNumber] = findMinAndCal(C)
	matrix = C.matrix;
	sizeMatrix = C.sizeMatrix;
	star = C.star;
	markedRows = C.markedRows;
	markedColumns = C.markedColumns;
	minNumber = intmax;

	for r = 1:sizeMatrix
		for c = 1:sizeMatrix
			if (markedRows(r) == false && markedColumns(c) == false)
				minNumber = min(minNumber, matrix(r,c));
			end
		end
	end

	for r = 1:sizeMatrix
		for c = 1:sizeMatrix
			if (markedRows(r) == true && markedColumns(c) == true)
				matrix(r,c) += minNumber;
			end

			if (markedRows(r) == false && markedColumns(c) == false)
				matrix(r,c) -= minNumber;
			end
		end
	end

	for r = 1:sizeMatrix
		for c = 1:sizeMatrix
			if (star(r,c) == true && matrix(r,c) != 0)
				star(r,c) = false;
			end
		end
	end

	result = C;
	result.matrix = matrix;
	result.star = star;
	result.markedRows = markedRows;
	result.markedColumns = markedColumns;
end


%%-----------------------------------------------------------------------------
%% Step 5.2: UnMark
function result = unMark(C)
	sizeMatrix = C.sizeMatrix;
	star = C.star;
	markedRows = C.markedRows;
	markedColumns = C.markedColumns;

	%% Unmarked matrix
	for r = 1:sizeMatrix
		for c = 1:sizeMatrix
			if (markedRows(r) == true)
				markedRows(r) = false;
			end

			if (markedColumns(r) == true)
				markedColumns(r) = false;
			end

			if star(r,c) == true
				star(r,c) = false;
			end
		end
	end

	result = C;
	result.star = star;
	result.markedRows = markedRows;
	result.markedColumns = markedColumns;
end


%%-----------------------------------------------------------------------------
%% Step 6: Optimized matrix
function result = optimizedMatrix(C)
	matrix = C.matrix;
	sizeMatrix = C.sizeMatrix;
	markedRows = C.markedRows;
	markedColumns = C.markedColumns;
	index = 0;
	count = 0;     			%% Number of zeros in a row or a columns        
	numbOfMarkedColumns = 0;
	
	firstZero = false;    

	while true
		for r = 1:sizeMatrix
			for c = 1:sizeMatrix
				if (matrix(r,c) == 0 && markedRows(r) == false && markedColumns(c) == false)
					index = c;
					count++;
				end
			end

			if count == 1
				matrix(:,index) = 0;
				matrix(r,:) = 0;
				matrix(r,index) = 1;
				markedRows(r) = true;
				markedColumns(index) = true;
				numbOfMarkedColumns++;
			end

			count = 0;
		end

		if (numbOfMarkedColumns == sizeMatrix)
			break;
		end

		for c = 1:sizeMatrix
			for r = 1:sizeMatrix
				if (matrix(r,c) == 0 && markedRows(r) == false && markedColumns(c) == false)
					index = r;
					count++;
				end
			end

			if count == 1
				matrix(index,:) = 0;
				matrix(:,c) = 0;
				matrix(index,c) = 1;
				markedRows(index) = true;
				markedColumns(c) = true;
				numbOfMarkedColumns++;
			end

			count = 0;
		end

		if (numbOfMarkedColumns == sizeMatrix)
			break;
		end

		for r = 1:sizeMatrix
			for c = 1:sizeMatrix
				if (matrix(r,c) == 0 && markedRows(r) == false && markedColumns(c) == false)
					matrix(:,c) = 0;
					matrix(r,:) = 0;
					matrix(r,c) = 1;
					markedRows(r) = true;
					markedColumns(c) = true;
					numbOfMarkedColumns++;
					firstZero = true;
					break;
				end
			end

			if firstZero
				break;
			end
		end

		if (numbOfMarkedColumns == sizeMatrix)
			break;
		end
	end

	result = C;
	result.matrix = matrix;
end


%%-----------------------------------------------------------------------------
%% Calculating function F(Xopt)
function f = calcF(C, X)
	matrix = C.matrix;
    sizeMatrix = C.sizeMatrix;
    f = 0;

    for r = 1:sizeMatrix
        for c = 1:sizeMatrix
            f = f + matrix(r,c) * X(r,c);
        end
    end
end