function Hungarian()
    clc();
    MAXIMIZATION = false;

    fprintf('\n\n\n\n\n---------------------------\n\n');

    C_initial = initialMatrix();

    dispC(C_initial, 'Given matrix C');
    
    C = subColumnMin(C_initial);
    dispC(C, 'After subtraction columns');

    C = subRowMin(C);
    dispC(C, 'After subtraction rows');

    C = markStarZeros(C);
    dispC(C, 'Marked *');



    C = markPlusZeros(C);
    dispC(C, 'Marked +');



end

%%-----------------------------------------------------------------------------
%% Setup matrix C
function C = SetupMatrixC(matrix, sizeMatrix, star, markedRows, markedColumns)
	C = struct('matrix', matrix, 'sizeMatrix', sizeMatrix, 'star', star, 'markedRows',markedRows, 'markedColumns', markedColumns);
end

%%-----------------------------------------------------------------------------
%% Initial matrix
function C = initialMatrix()
    matrix = [4 10 7 3 6; 5 6 2 7 4; 9 5 6 8 3; 2 3 5 4 8; 8 5 4 9 3];

    [rows, cols] = size(matrix);
    assert(rows == cols, 'Matrix should be square!');

    %% This matrix for save data
    tmpMatrix = zeros(rows,cols);

    C = SetupMatrixC(matrix, rows, tmpMatrix, tmpMatrix(:,1), tmpMatrix(1,:));
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
%% Subtract all columns by minimum value
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
%% Subtract all rows by minimum value
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
%% Mark 0* in the matrix
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

%% Mark columns or rows with plus
function result = markPlusZeros(C)
	matrix = C.matrix;
	sizeMatrix = C.sizeMatrix;
	markedRows = C.markedRows;
	markedColumns = C.markedColumns;
	count = 0;     %% Count zero in a row or a columns
	plus = 0;			%% Count plus

	for r = 1:sizeMatrix
		for c = 1:sizeMatrix
			if matrix(r,c) == 0
				count++;
			end
		end

		if count > 1
			markedRows(r) = true;
			plus++;
		end

		count = 0;
	end

	for c = 1:sizeMatrix
		for r = 1:sizeMatrix
			if matrix(r,c) == 0
				count++;
			end
		end

		if count > 1
			markedColumns(c) = true;
			plus++;
		end

		count = 0;
	end

	for r = 1:sizeMatrix
		for c = 1:sizeMatrix
			if (matrix(r,c) == 0 && markedRows(r) == false && markedColumns(c) == false)
				markedRows(r) = true;
				plus++;
			end
		end
	end

	result = C;
	result.markedRows = markedRows;
	result.markedColumns = markedColumns;
end